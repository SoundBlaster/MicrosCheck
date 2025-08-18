import Combine
import Foundation
#if canImport(AVFoundation)
    import AVFoundation
#endif

// MARK: - Data Models required for metadata/bookmarks

struct AudioFileID: Hashable, Codable {
    let path: String
}

struct AudioAttributes: Codable {
    var duration: TimeInterval
    var bitrateKbps: Int?
    var sampleRate: Double
    var channels: Int
    var format: AudioFormat
    var fileSizeBytes: Int64
}

enum AudioFormat: String, Codable { case aac /*default*/, pcm, alac /*…*/ }

struct FileMeta: Codable {
    var id: AudioFileID
    var displayName: String
    var createdAt: Date
    var lastPlayedPosition: TimeInterval?
    var bookmarks: [Bookmark]
    var audio: AudioAttributes
    var userTags: [String]
    var custom: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case createdAt
        case lastPlayedPosition
        case bookmarks
        case audio
        case userTags
        case custom
    }
}

/// Represents a single audio file and its basic metadata for the file list UI.
struct RecordingFileInfo: Identifiable, Equatable {
    let id: UUID = UUID()
    let url: URL
    let name: String
    let size: UInt64
    let created: Date?
    let duration: TimeInterval?
}

@MainActor
final class FileListViewModel: ObservableObject {
    @Published var files: [RecordingFileInfo] = []
    @Published var isLoading: Bool = false

    /// Cached waveform data per file URL
    @Published private(set) var waveformCache: [URL: WaveformData] = [:]

    private let fileReader: FileReader
    private let waveformGenerator: WaveformGenerator

    init(fileReader: FileReader) {
        self.fileReader = fileReader
        // Initialize waveform generator with a cache directory
        let cacheDir = fileReader.getDocumentsDirectory().appendingPathComponent(
            "Cache/Waveforms", isDirectory: true)
        self.waveformGenerator = WaveformGenerator(cacheDirectory: cacheDir)
        Task { await reload() }
    }

    /// Reloads files and enforces waveform cache size limits asynchronously.
    func reloadWithCacheCleanup() async {
        await reload()
        do {
            try await waveformGenerator.enforceCacheSizeLimit()
        } catch {
            print("FileListViewModel: waveform cache cleanup failed: \(error)")
        }
    }

    /// Reloads the list of audio files from the /Documents/Recordings directory.
    func reload() async {
        isLoading = true
        defer { isLoading = false }
        let dir = fileReader.getRecordingsDirectory()
        let fm = FileManager.default
        var fileInfos: [RecordingFileInfo] = []
        var newCache: [URL: WaveformData] = [:]
        if let files = (try? fm.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey],
            options: [.skipsHiddenFiles])) as? [URL]
        {
            for url in files where url.pathExtension.lowercased() == "m4a" {
                let name = url.lastPathComponent
                let size = fileReader.fileSize(for: url)
                let attrs = try? fm.attributesOfItem(atPath: url.path)
                let created = attrs?[.creationDate] as? Date
                let duration = FileListViewModel.audioDuration(for: url)

                // Attempt to load bookmarks from associated JSON metadata file
                var bookmarks: [Bookmark] = []
                let metaURL = url.deletingPathExtension().appendingPathExtension("json")
                if let metaData = try? Data(contentsOf: metaURL),
                    let fileMeta = try? JSONDecoder().decode(FileMeta.self, from: metaData)
                {
                    bookmarks = fileMeta.bookmarks
                }

                // Compose RecordingFileInfo with bookmarks as custom user data (if needed)
                let fileInfo = RecordingFileInfo(
                    url: url, name: name, size: size, created: created, duration: duration)

                fileInfos.append(fileInfo)

                // Load cached waveform data asynchronously, will not block UI reload
                Task.detached { [weak self] in
                    guard let self else { return }
                    do {
                        let waveform = try await self.waveformGenerator.generateWaveform(for: url)
                        await MainActor.run {
                            newCache[url] = waveform
                            self.waveformCache = newCache
                        }
                    } catch {
                        // Ignore load failures, keep cache missing
                        print(
                            "WaveformGenerator: failed to load/generate waveform for \(url): \(error)"
                        )
                    }
                }
            }
        }
        // Sort by most recent
        self.files = fileInfos.sorted {
            ($0.created ?? .distantPast) > ($1.created ?? .distantPast)
        }
    }

    /// Helper to get duration of an audio file (m4a) using AVFoundation.
    private static func audioDuration(for url: URL) -> TimeInterval? {
        #if canImport(AVFoundation)
            let asset = AVURLAsset(url: url)
            return CMTimeGetSeconds(asset.duration)
        #else
            return nil
        #endif
    }

    // MARK: - File Operations

    /// Copies a file to a new name asynchronously.
    /// - Parameters:
    ///   - file: The file to copy.
    ///   - newName: The new name for the copied file.
    /// - Returns: The URL of the new copied file.
    func copy(file: RecordingFileInfo, to newName: String) async throws -> URL {
        let fm = FileManager.default
        let newURL = file.url.deletingLastPathComponent().appendingPathComponent(newName)
        try await Task.detached {
            if fm.fileExists(atPath: newURL.path) {
                try fm.removeItem(at: newURL)
            }
            try fm.copyItem(at: file.url, to: newURL)
        }.value
        await reload()
        return newURL
    }

    /// Deletes a file asynchronously.
    /// - Parameter file: The file to delete.
    func delete(file: RecordingFileInfo) async throws {
        let fm = FileManager.default
        try await Task.detached {
            if fm.fileExists(atPath: file.url.path) {
                try fm.removeItem(at: file.url)
            }
        }.value
        await reload()
    }

    /// Renames a file asynchronously.
    /// - Parameters:
    ///   - file: The file to rename.
    ///   - newName: The new name for the file.
    /// - Returns: The URL of the renamed file.
    func rename(file: RecordingFileInfo, to newName: String) async throws -> URL {
        let fm = FileManager.default
        let newURL = file.url.deletingLastPathComponent().appendingPathComponent(newName)
        try await Task.detached {
            if fm.fileExists(atPath: newURL.path) {
                try fm.removeItem(at: newURL)
            }
            try fm.moveItem(at: file.url, to: newURL)
        }.value
        await reload()
        return newURL
    }

    // MARK: - FM4: Query Free Disk Space

    /// Returns the free disk space in bytes asynchronously.
    func freeDiskSpaceBytes() async throws -> Int64 {
        let fm = FileManager.default
        return try await Task.detached {
            let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first
            guard let url = url else { return 0 }
            let values = try url.resourceValues(forKeys: [
                .volumeAvailableCapacityForImportantUsageKey
            ])
            return values.volumeAvailableCapacityForImportantUsage ?? 0
        }.value
    }
    
    /// Loads and returns the FileMeta for the given AudioFileID by reading its metadata JSON file.
    func attributes(for id: AudioFileID) async throws -> FileMeta {
        let metaUrl = URL(fileURLWithPath: id.path).deletingPathExtension().appendingPathExtension("json")
        let data = try Data(contentsOf: metaUrl)
        let meta = try JSONDecoder().decode(FileMeta.self, from: data)
        return meta
    }

    /// Saves the provided FileMeta to its metadata JSON file.
    func updateMeta(_ meta: FileMeta) async throws {
        let metaUrl = URL(fileURLWithPath: meta.id.path).deletingPathExtension().appendingPathExtension("json")
        let data = try JSONEncoder().encode(meta)
        try data.write(to: metaUrl)
    }
}
