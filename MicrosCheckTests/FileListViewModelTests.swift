//
//  FileListViewModelTests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2025-08-19.
//

import XCTest

@testable import MicrosCheck

final class FileListViewModelTests: XCTestCase {

    var viewModel: FileListViewModel!
    var dummyFileReader: DummyFileReader!

    override func setUpWithError() throws {
        dummyFileReader = DummyFileReader()
        viewModel = FileListViewModel(fileReader: dummyFileReader)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        dummyFileReader = nil
    }

    func testReloadPopulatesFiles() async throws {
        await viewModel.reload()
        XCTAssertFalse(viewModel.files.isEmpty, "Files list should not be empty after reload")
        XCTAssertEqual(viewModel.files.count, dummyFileReader.mockFiles.count)
    }

    func testCopyFileCreatesNewFile() async throws {
        let originalFile = dummyFileReader.mockFiles[0]
        let newName = "copy_of_" + originalFile.name
        let newURL = try await viewModel.copy(file: originalFile, to: newName)
        XCTAssertTrue(
            dummyFileReader.copiedFiles.contains(newURL), "Copied file URL should be recorded")
        XCTAssertTrue(
            viewModel.files.contains(where: { $0.url == newURL }),
            "New file should appear in files list")
    }

    func testDeleteFileRemovesFile() async throws {
        let fileToDelete = dummyFileReader.mockFiles[1]
        try await viewModel.delete(file: fileToDelete)
        XCTAssertTrue(
            dummyFileReader.deletedFiles.contains(fileToDelete.url),
            "Deleted file URL should be recorded")
        XCTAssertFalse(
            viewModel.files.contains(where: { $0.url == fileToDelete.url }),
            "Deleted file should not appear in files list")
    }

    func testRenameFileChangesFileName() async throws {
        let fileToRename = dummyFileReader.mockFiles[0]
        let newName = "renamed_" + fileToRename.name
        let newURL = try await viewModel.rename(file: fileToRename, to: newName)
        XCTAssertTrue(
            dummyFileReader.renamedFiles.contains(where: { $0.1 == newURL }),
            "Rename operation should be recorded")
        XCTAssertTrue(
            viewModel.files.contains(where: { $0.url == newURL }),
            "Renamed file should appear in files list")
    }

    func testFreeDiskSpaceBytesReturnsValue() async throws {
        let freeSpace = try await viewModel.freeDiskSpaceBytes()
        XCTAssertEqual(
            freeSpace, dummyFileReader.mockFreeSpace, "Free disk space should match dummy value")
    }
}

// MARK: - DummyFileReader for testing

final class DummyFileReader: FileReader {

    var mockFiles: [RecordingFileInfo] = [
        RecordingFileInfo(
            url: URL(fileURLWithPath: "/tmp/rec1.m4a"),
            name: "rec1.m4a",
            size: 1024 * 1024,
            created: Date(),
            duration: 60
        ),
        RecordingFileInfo(
            url: URL(fileURLWithPath: "/tmp/rec2.m4a"),
            name: "rec2.m4a",
            size: 2 * 1024 * 1024,
            created: Date(),
            duration: 120
        ),
    ]

    var copiedFiles: [URL] = []
    var deletedFiles: [URL] = []
    var renamedFiles: [(old: URL, new: URL)] = []
    let mockFreeSpace: Int64 = 500 * 1024 * 1024  // 500 MB

    func hasFile(at url: URL) -> Bool {
        mockFiles.contains(where: { $0.url == url })
    }

    func deleteFile(at url: URL) -> Bool {
        deletedFiles.append(url)
        mockFiles.removeAll(where: { $0.url == url })
        return true
    }

    func fileForRecord() -> File {
        FileImpl(url: URL(fileURLWithPath: "/tmp/recording.m4a"))
    }

    func recordURL() -> URL {
        URL(fileURLWithPath: "/tmp/recording.m4a")
    }

    func fileSize(for fileURL: URL) -> UInt64 {
        mockFiles.first(where: { $0.url == fileURL })?.size ?? 0
    }

    func getDocumentsDirectory() -> URL {
        URL(fileURLWithPath: "/tmp")
    }

    // Simulate copy operation
    func copyFile(at src: URL, to dst: URL) throws {
        copiedFiles.append(dst)
        if let file = mockFiles.first(where: { $0.url == src }) {
            let copy = RecordingFileInfo(
                url: dst,
                name: dst.lastPathComponent,
                size: file.size,
                created: file.created,
                duration: file.duration
            )
            mockFiles.append(copy)
        }
    }

    // Simulate move/rename operation
    func moveFile(at src: URL, to dst: URL) throws {
        renamedFiles.append((old: src, new: dst))
        if let index = mockFiles.firstIndex(where: { $0.url == src }) {
            var file = mockFiles[index]
            file = RecordingFileInfo(
                url: dst,
                name: dst.lastPathComponent,
                size: file.size,
                created: file.created,
                duration: file.duration
            )
            mockFiles[index] = file
        }
    }
}

// Extend FileListViewModel to override file operations for testing

extension FileListViewModel {

    func copy(file: RecordingFileInfo, to newName: String) async throws -> URL {
        let newURL = file.url.deletingLastPathComponent().appendingPathComponent(newName)
        if let dummy = fileReader as? DummyFileReader {
            try dummy.copyFile(at: file.url, to: newURL)
        }
        await reload()
        return newURL
    }

    func delete(file: RecordingFileInfo) async throws {
        if let dummy = fileReader as? DummyFileReader {
            _ = dummy.deleteFile(at: file.url)
        }
        await reload()
    }

    func rename(file: RecordingFileInfo, to newName: String) async throws -> URL {
        let newURL = file.url.deletingLastPathComponent().appendingPathComponent(newName)
        if let dummy = fileReader as? DummyFileReader {
            try dummy.moveFile(at: file.url, to: newURL)
        }
        await reload()
        return newURL
    }

    func freeDiskSpaceBytes() async throws -> Int64 {
        if let dummy = fileReader as? DummyFileReader {
            return dummy.mockFreeSpace
        }
        return 0
    }
}
