//
//  Bookmarks.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 2025-08-19.
//

import Foundation
import SwiftUI

// MARK: - Bookmark Model

struct Bookmark: Identifiable, Codable, Equatable {
    let id: UUID
    var time: TimeInterval
    var title: String?
    var note: String?
    var createdAt: Date

    init(time: TimeInterval, title: String? = nil, note: String? = nil) {
        self.id = UUID()
        self.time = time
        self.title = title
        self.note = note
        self.createdAt = Date()
    }
}

// MARK: - Extension to FileMeta to manage bookmarks

extension FileMeta {
    mutating func addBookmark(_ bookmark: Bookmark) {
        bookmarks.append(bookmark)
        bookmarks.sort { $0.time < $1.time }
    }

    mutating func removeBookmark(_ bookmark: Bookmark) {
        bookmarks.removeAll { $0.id == bookmark.id }
    }

    mutating func updateBookmark(_ bookmark: Bookmark) {
        if let index = bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            bookmarks[index] = bookmark
            bookmarks.sort { $0.time < $1.time }
        }
    }
}

// MARK: - Bookmark Management in FileListViewModel

@MainActor
extension FileListViewModel {

    /// Adds a bookmark at the given time to the specified file.
    func addBookmark(
        to file: RecordingFileInfo, time: TimeInterval, title: String? = nil, note: String? = nil
    ) async throws {
        // Load current metadata
        guard var meta = try? await attributes(for: AudioFileID(path: file.url.path)) else {
            throw NSError(
                domain: "FileListViewModel", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "File metadata not found"])
        }
        // Create and add bookmark
        let bookmark = Bookmark(time: time, title: title, note: note)
        meta.addBookmark(bookmark)
        // Save updated metadata
        try await updateMeta(meta)
        // Reload files to update UI
        await reload()
    }

    /// Removes a bookmark from the specified file.
    func removeBookmark(from file: RecordingFileInfo, bookmark: Bookmark) async throws {
        guard var meta = try? await attributes(for: AudioFileID(path: file.url.path)) else {
            throw NSError(
                domain: "FileListViewModel", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "File metadata not found"])
        }
        meta.removeBookmark(bookmark)
        try await updateMeta(meta)
        await reload()
    }

    /// Updates a bookmark in the specified file.
    func updateBookmark(in file: RecordingFileInfo, bookmark: Bookmark) async throws {
        guard var meta = try? await attributes(for: AudioFileID(path: file.url.path)) else {
            throw NSError(
                domain: "FileListViewModel", code: 3,
                userInfo: [NSLocalizedDescriptionKey: "File metadata not found"])
        }
        meta.updateBookmark(bookmark)
        try await updateMeta(meta)
        await reload()
    }
}

// MARK: - Bookmark UI Component

struct BookmarkButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Add Bookmark", systemImage: "mappin")
                .labelStyle(.iconOnly)
                .font(.title2)
                .padding(8)
        }
        .buttonStyle(.borderedProminent)
        .help("Add a bookmark at the current position")
    }
}

// MARK: - Preview for BookmarkButton

#if DEBUG
    struct BookmarkButton_Previews: PreviewProvider {
        static var previews: some View {
            BookmarkButton(action: { print("Bookmark added") })
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
#endif
