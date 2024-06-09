//
//  AppState.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 09.06.2024.
//

import Observation

@Observable
final class AppState {
    // The name of selected input for recording.
    var selectedInputName: String = .notSelectedInputName
    // Recording is active now.
    var isRecording: Bool = false
    // Playing record is active now.
    var isPlaying: Bool = false
    // Recorder.
    let recorder: Recorder = Recorder()
    // Player.
    var player: AudioPlayer?

    init() {
        _ = FileReader.deleteFile(at: FileReader.recordURL())
    }
}
