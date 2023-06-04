//
//  FileReader.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 07.05.2023.
//

import Foundation

class FileReader {
    
    static func hasFile(at url: URL) -> Bool {
        guard url.isFileURL else {
            return false
        }
        
        return FileManager
            .default
            .fileExists(atPath: url.path)
    }
    
    static func deleteFile(at url: URL) -> Bool {
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
    
}

extension FileReader {
    
    public static func recordURL() -> URL {
        getDocumentsDirectory().appendingPathComponent("recording.m4a")
    }
    
    public static func fileSize(for fileURL: URL) -> UInt64 {
        let attributes = try? FileManager
            .default
            .attributesOfFileSystem(forPath: fileURL.path)
        guard let attributesDict = attributes as? NSDictionary else {
            return 0
        }
        return attributesDict.fileSize()
    }
    
    private static func getDocumentsDirectory() -> URL {
        FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
