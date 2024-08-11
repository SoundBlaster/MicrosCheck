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
            .isDeletableFile(atPath: url.path) { 
            try? FileManager.default.removeItem(atPath: url.path)
            return true
        }
        return false
    }

    func fileForRecord() -> File {
        FileImpl(url: recordURL())
    }

    func recordURL() -> URL {
        getDocumentsDirectory().appendingPathComponent("recording.m4a")
    }
    
    func fileSize(for fileURL: URL) -> UInt64 {
        let attributes = try? FileManager
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
}
