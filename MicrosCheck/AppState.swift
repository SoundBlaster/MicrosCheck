//
//  AppState.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 09.06.2024.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    // The name of selected input for recording.
    var selectedInputName: String = .notSelectedInputName
    // Recording is active now.
    var isRecording: Bool = false
    // Playing record is active now.
    var isPlaying: Bool = false
    // Audio Session is ready for input & output operations.
    var isPrepared: Bool = false
    // Recorder.
    let recorder: Recorder = RecorderImpl(fileReader: fileReader())
    // Player.
    var player: AudioPlayer?
    // File Reader
    let fileReader: FileReader = fileReader()
    // Recording Settings Store
    let recordingSettingsStore: RecordingSettingsStore = RecordingSettingsStore()

    init() {
        #if DEBUG
            // TODO: Remove cleanup, its just for debug
            _ = fileReader.deleteFile(at: fileReader.recordURL())
        #endif
    }

    private static func fileReader() -> FileReader {
        FileReaderImpl()
    }
}
