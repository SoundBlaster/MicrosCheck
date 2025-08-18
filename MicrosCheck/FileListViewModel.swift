import Combine
import Foundation

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

    private let fileReader: FileReader

    init(fileReader: FileReader) {
        self.fileReader = fileReader
        Task { await reload() }
    }

    /// Reloads the list of audio files from the /Documents/Recordings directory.
    func reload() async {
        isLoading = true
        defer { isLoading = false }
        let dir = fileReader.getDocumentsDirectory().appendingPathComponent(
            "Recordings", isDirectory: true)
        let fm = FileManager.default
        var fileInfos: [RecordingFileInfo] = []
        if let files = try? fm.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey],
            options: [.skipsHiddenFiles])
        {
            for url in files where url.pathExtension.lowercased() == "m4a" {
                let name = url.lastPathComponent
                let size = fileReader.fileSize(for: url)
                let attrs = try? fm.attributesOfItem(atPath: url.path)
                let created = attrs?[.creationDate] as? Date
                let duration = FileListViewModel.audioDuration(for: url)
                fileInfos.append(
                    RecordingFileInfo(
                        url: url, name: name, size: size, created: created, duration: duration))
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
            import AVFoundation
            let asset = AVURLAsset(url: url)
            return CMTimeGetSeconds(asset.duration)
        #else
            return nil
        #endif
    }
}
