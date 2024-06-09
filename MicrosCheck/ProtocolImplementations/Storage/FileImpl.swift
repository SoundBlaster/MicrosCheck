//
//  FileImpl.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 09.06.2024.
//

import Foundation

final class FileImpl: File {
    // MARK: File
    var url: URL

    init(url: URL) {
        self.url = url
    }
}
