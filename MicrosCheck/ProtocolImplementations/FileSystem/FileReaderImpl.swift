import Foundation

final class FileReaderImpl: FileReader {

    func hasFile(at url: URL) -> Bool {
        guard url.isFileURL else {
            return false
        }

        return FileManager
            .default
            .fileExists(atPath: url.path)
    }

    func deleteFile(at url: URL) -> Bool {
        guard url.isFileURL else {
            return false
        }

        if FileManager
            .default
            .isDeletableFile(atPath: url.path)
        {
            try? FileManager.default.removeItem(atPath: url.path)
            return true
        }
        return false
    }

    func fileForRecord() -> File {
        FileImpl(url: recordURL())
    }

    func recordURL() -> URL {
        let recordingsDir = getRecordingsDirectory()
        return recordingsDir.appendingPathComponent("recording.m4a")
    }

    func fileSize(for fileURL: URL) -> UInt64 {
        let attributes =
            try? FileManager
            .default
            .attributesOfItem(atPath: fileURL.path)
        guard let attributesDict = attributes as? NSDictionary else {
            return 0
        }
        return attributesDict.fileSize()
    }

    func getDocumentsDirectory() -> URL {
        FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Returns the recordings directory URL `/Documents/Recordings`.
    /// Ensures the directory exists, creates if missing.
    func getRecordingsDirectory() -> URL {
        let recordingsDir = getDocumentsDirectory().appendingPathComponent(
            "Recordings", isDirectory: true)
        ensureRecordingsDirectoryExists(at: recordingsDir)
        return recordingsDir
    }

    /// Ensures the `/Documents/Recordings` directory exists.
    /// Creates it if missing, handles any errors internally.
    private func ensureRecordingsDirectoryExists(at url: URL) {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: url.path, isDirectory: &isDir) {
            if !isDir.boolValue {
                // Exists but not a directory - handle error by renaming or deleting
                do {
                    try fm.removeItem(at: url)
                    try fm.createDirectory(at: url, withIntermediateDirectories: true)
                } catch {
                    print("Error replacing file with directory at \(url): \(error)")
                }
            }
        } else {
            do {
                try fm.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print("Failed to create recordings directory \(url): \(error)")
            }
        }
    }
}
