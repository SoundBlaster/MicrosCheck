//
//  AudioPlayer.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 26.05.2024.
//

import Foundation

protocol File {
    var url: URL { get }
}

protocol AudioPlayer {
    var file: File { get }
    func play()
    func pause()
    func stop()
}
