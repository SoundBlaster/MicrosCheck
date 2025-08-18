//
//  RecorderViewModelTests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2025-08-19.
//

import XCTest

@testable import MicrosCheck

final class RecorderViewModelTests: XCTestCase {

    var appState: AppState!
    var viewModel: RecorderViewModel!

    override func setUpWithError() throws {
        appState = AppState()
        viewModel = RecorderViewModel(appState: appState)
    }

    override func tearDownWithError() throws {
        appState = nil
        viewModel = nil
    }

    func testInitialState() throws {
        XCTAssertFalse(viewModel.isRecording)
        XCTAssertFalse(viewModel.isPrepared)
        XCTAssertEqual(viewModel.elapsed, 0)
        XCTAssertEqual(viewModel.fileName, "")
        XCTAssertEqual(viewModel.fileSize, 0)
        XCTAssertEqual(viewModel.format, "AAC 128kbps")
        XCTAssertEqual(viewModel.leftLevel, -60)
        XCTAssertEqual(viewModel.rightLevel, -60)
    }

    func testPrepareSuccess() async throws {
        await viewModel.prepare()
        XCTAssertTrue(viewModel.isPrepared)
    }

    func testRecordPauseStopTransitions() throws {
        // Prepare recorder in appState to allow recording
        try appState.recorder.prepare()

        // Start recording
        viewModel.record()
        XCTAssertTrue(viewModel.isRecording)
        XCTAssertTrue(appState.recorder.recording)

        // Pause recording
        viewModel.pause()
        XCTAssertFalse(viewModel.isRecording)
        XCTAssertFalse(appState.recorder.recording)

        // Resume recording
        viewModel.record()
        XCTAssertTrue(viewModel.isRecording)
        XCTAssertTrue(appState.recorder.recording)

        // Stop recording
        viewModel.stop()
        XCTAssertFalse(viewModel.isRecording)
        XCTAssertFalse(appState.recorder.recording)
    }

    func testMeterUpdatesWhileRecording() throws {
        try appState.recorder.prepare()
        viewModel.record()

        // Simulate meter update call
        viewModel.updateMeters()

        // Levels should be within valid dB range
        XCTAssertGreaterThanOrEqual(viewModel.leftLevel, -60)
        XCTAssertLessThanOrEqual(viewModel.leftLevel, 0)
        XCTAssertGreaterThanOrEqual(viewModel.rightLevel, -60)
        XCTAssertLessThanOrEqual(viewModel.rightLevel, 0)

        // Elapsed time should be non-negative
        XCTAssertGreaterThanOrEqual(viewModel.elapsed, 0)

        // File name should not be empty
        XCTAssertFalse(viewModel.fileName.isEmpty)
    }
}

extension RecorderViewModel {
    /// Expose updateMeters for testing
    func updateMeters() {
        let recorder = appState.recorder
        guard recorder.recording else { return }
        if let avRecorder = recorder.value(forKey: "audioRecorder") as? AVAudioRecorder {
            avRecorder.updateMeters()
            leftLevel = avRecorder.averagePower(forChannel: 0)
            if avRecorder.numberOfChannels > 1 {
                rightLevel = avRecorder.averagePower(forChannel: 1)
            } else {
                rightLevel = leftLevel
            }
            elapsed = avRecorder.currentTime
        }
        fileName = recorder.activeUrl?.lastPathComponent ?? ""
        fileSize = appState.fileReader.fileSize(
            for: recorder.activeUrl ?? appState.fileReader.recordURL())
    }
}
