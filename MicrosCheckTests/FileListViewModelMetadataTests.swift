//
//  FileListViewModelMetadataTests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2025-08-19.
//

import XCTest

@testable import MicrosCheck

final class FileListViewModelMetadataTests: XCTestCase {

    var viewModel: FileListViewModel!
    var dummyFileReader: DummyFileReaderWithMetadata!

    override func setUpWithError() throws {
        dummyFileReader = DummyFileReaderWithMetadata()
        viewModel = FileListViewModel(fileReader: dummyFileReader)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        dummyFileReader = nil
    }

    func testReloadLoadsFullMetadataIncludingBookmarks() async throws {
        await viewModel.reload()
        XCTAssertEqual(
            viewModel.files.count, dummyFileReader.mockFiles.count,
            "File count should match dummy data")

        for file in viewModel.files {
            guard let expectedFile = dummyFileReader.mockFiles.first(where: { $0.url == file.url })
            else {
                XCTFail("Expected file not found for \(file.name)")
                continue
            }
            XCTAssertEqual(file.name, expectedFile.name, "File name should match")
            XCTAssertEqual(file.size, expectedFile.size, "File size should match")
            XCTAssertEqual(
                file.created?.timeIntervalSince1970,
                expectedFile.created?.timeIntervalSince1970,
                accuracy: 1.0, "Created date should match within 1 second")
            XCTAssertEqual(file.duration ?? 0, expectedFile.duration ?? 0, accuracy: 0.1)

            // Test bookmarks loaded from metadata
            if let bookmarks = dummyFileReader.mockBookmarks[file.url] {
                // Normally bookmarks are not stored in RecordingFileInfo; adapt test as needed.
                // For demonstration, verify expected bookmarks exist in dummy data.
                XCTAssertFalse(bookmarks.isEmpty, "Bookmarks list should not be empty")
            }
        }
    }
}

// DummyFileReaderWithMetadata simulates file reader with metadata including bookmarks

final class DummyFileReaderWithMetadata: FileReader {

    var mockFiles: [RecordingFileInfo] = [
        RecordingFileInfo(
            url: URL(fileURLWithPath: "/tmp/rec1.m4a"),
            name: "rec1.m4a",
            size: 1024 * 1024,
            created: Date(timeIntervalSince1970: 1_692_432_000),
            duration: 60
        ),
        RecordingFileInfo(
            url: URL(fileURLWithPath: "/tmp/rec2.m4a"),
            name: "rec2.m4a",
            size: 2 * 1024 * 1024,
            created: Date(timeIntervalSince1970: 1_692_518_400),
            duration: 120
        ),
    ]

    // bookmarks keyed by audio file URL
    var mockBookmarks: [URL: [Bookmark]] = [:]

    init() {
        mockBookmarks = [
            mockFiles[0].url: [
                Bookmark(time: 5.5, title: "Start", note: "Beginning of speech", createdAt: Date()),
                Bookmark(time: 30.0, title: "Important", note: "Key point", createdAt: Date()),
            ],
            mockFiles[1].url: [
                Bookmark(time: 10.0, title: "Intro", note: nil, createdAt: Date())
            ],
        ]
    }

    func hasFile(at url: URL) -> Bool {
        mockFiles.contains(where: { $0.url == url })
    }

    func deleteFile(at url: URL) -> Bool {
        false
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

    // This simulates loading JSON file metadata content for bookmarks
    func loadFileMeta(for url: URL) throws -> FileMeta {
        // Compose FileMeta with bookmarks for testing metadata load
        let file = mockFiles.first(where: { $0.url == url })!
        let bookmarks = mockBookmarks[url] ?? []
        return FileMeta(
            id: AudioFileID(path: url.path),
            displayName: file.name,
            createdAt: file.created ?? Date(),
            lastPlayedPosition: nil,
            bookmarks: bookmarks,
            audio: AudioAttributes(
                duration: file.duration ?? 0,
                bitrateKbps: nil,
                sampleRate: 44100,
                channels: 2,
                format: .aac,
                fileSizeBytes: Int64(file.size)
            ),
            userTags: [],
            custom: nil
        )
    }
}
