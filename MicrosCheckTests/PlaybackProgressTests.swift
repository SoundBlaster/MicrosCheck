//
//  PlaybackProgressTests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2025-08-19.
//

import AVFoundation
import XCTest

@testable import MicrosCheck

final class PlaybackProgressTests: XCTestCase {

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

    func testPlaybackPositionInitialAndUpdate() throws {
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
        XCTAssertEqual(
            playbackVM.position, 0.0, accuracy: 0.01, "Initial playback position should be 0")

        playbackVM.play()
        XCTAssertTrue(playbackVM.isPlaying, "Playback should be playing after play()")

        // Wait a moment to allow position update
        let exp = expectation(description: "Wait for playback position update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        let pos = playbackVM.position
        XCTAssertGreaterThan(pos, 0, "Playback position should advance after some time")

        playbackVM.pause()
        let pausedPos = playbackVM.position
        XCTAssertFalse(playbackVM.isPlaying, "Playback should be paused after pause()")

        // Wait a bit and confirm position does not advance while paused
        let exp2 = expectation(description: "Wait while paused")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 1.0)

        XCTAssertEqual(
            playbackVM.position, pausedPos, accuracy: 0.01,
            "Playback position should not advance while paused")
    }

    func testPlaybackPositionDoesNotDriftExcessively() throws {
        guard let fileURL = testFileURL else {
            XCTFail("Test audio file URL not found.")
            return
        }

        let fileInfo = RecordingFileInfo(
            url: fileURL,
            name: "test_audio.m4a",
            size: 123456,
            created: Date(),
            duration: 3600  // 1 hour for drift test
        )

        playbackVM.load(file: fileInfo)
        playbackVM.play()

        // Simulate position jump beyond maxJump tolerance of 5 seconds
        playbackVM.position = 10.0
        let largeJump = 20.0  // greater than max allowed 5 seconds
        playbackVM.seek(to: playbackVM.position + largeJump)

        // The position should NOT jump abruptly beyond maxJump and should remain close to old position
        XCTAssertLessThanOrEqual(
            abs(playbackVM.position - 10.0), 1.0,
            "Playback position should not jump abruptly more than allowed during seek")

        playbackVM.stop()
    }
}
