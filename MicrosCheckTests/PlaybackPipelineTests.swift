//
//  PlaybackPipelineTests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2025-08-19.
//

import AVFoundation
import XCTest

@testable import MicrosCheck

final class PlaybackPipelineTests: XCTestCase {

    var playbackVM: PlaybackViewModel!
    var testFileURL: URL!

    override func setUpWithError() throws {
        playbackVM = PlaybackViewModel()
        // Use a dummy or known test audio file URL if available,
        // otherwise set to a valid local file path for test purposes.
        testFileURL = Bundle.module.url(forResource: "test_audio", withExtension: "m4a")
        if testFileURL == nil {
            // Use a path to an accessible audio file for testing, else tests will skip
            testFileURL = URL(fileURLWithPath: "/tmp/test_audio.m4a")
        }
    }

    override func tearDownWithError() throws {
        playbackVM = nil
        testFileURL = nil
    }

    func testLoadPlayPauseStopSeekPipeline() throws {
        guard let fileURL = testFileURL else {
            XCTFail("Test audio file URL not found.")
            return
        }

        let fileInfo = RecordingFileInfo(
            url: fileURL,
            name: "test_audio.m4a",
            size: 123456,
            created: Date(),
            duration: 10.0
        )

        playbackVM.load(file: fileInfo)
        XCTAssertEqual(playbackVM.currentFile?.url, fileURL)

        // Test play
        playbackVM.play()
        XCTAssertTrue(playbackVM.isPlaying, "Playback should be playing after play()")

        // Wait a brief moment to simulate playback progress
        let expPlay = expectation(description: "Playback progress")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expPlay.fulfill()
        }
        wait(for: [expPlay], timeout: 1.0)

        // Test pause
        playbackVM.pause()
        XCTAssertFalse(playbackVM.isPlaying, "Playback should be paused after pause()")

        // Test resume play
        playbackVM.play()
        XCTAssertTrue(playbackVM.isPlaying, "Playback should be playing after play()")

        // Test seek within duration
        playbackVM.seek(to: 5.0)
        XCTAssertEqual(playbackVM.position, 5.0, accuracy: 0.1)

        // Test nudge forward and backward
        playbackVM.nudge(by: 2.0)
        XCTAssertEqual(playbackVM.position, 7.0, accuracy: 0.1)

        playbackVM.nudge(by: -3.0)
        XCTAssertEqual(playbackVM.position, 4.0, accuracy: 0.1)

        // Test seek beyond duration clamps to duration
        playbackVM.seek(to: playbackVM.duration + 10)
        XCTAssertLessThanOrEqual(playbackVM.position, playbackVM.duration)

        // Test seek below 0 clamps to 0
        playbackVM.seek(to: -5)
        XCTAssertGreaterThanOrEqual(playbackVM.position, 0)

        // Test stop
        playbackVM.stop()
        XCTAssertFalse(playbackVM.isPlaying, "Playback should be stopped after stop()")
        XCTAssertEqual(playbackVM.position, 0, "Position should be reset to 0 on stop")
    }
}
