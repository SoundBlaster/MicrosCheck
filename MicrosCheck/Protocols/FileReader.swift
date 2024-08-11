import Foundation

protocol FileReader {
    func hasFile(at url: URL) -> Bool
    func deleteFile(at url: URL) -> Bool
    func fileForRecord() -> File
    func recordURL() -> URL
    func fileSize(for fileURL: URL) -> UInt64
    func getDocumentsDirectory() -> URL
}
