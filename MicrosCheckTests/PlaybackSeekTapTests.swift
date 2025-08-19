//
//  PlaybackSeekTapTests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2025-08-19.
//

import AVFoundation
import XCTest

@testable import MicrosCheck

final class PlaybackSeekTapTests: XCTestCase {

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

    func testNudgeWithinBounds() throws {
        guard let fileURL = testFileURL else {
            XCTFail("Test audio file URL not found.")
            return
        }

        let fileInfo = RecordingFileInfo(
            url: fileURL,
            name: "test_audio.m4a",
            size: 123456,
            created: Date(),
            duration: 100.0
        )
        playbackVM.load(file: fileInfo)

        // Seek to initial position zero
        playbackVM.seek(to: 0)
        XCTAssertEqual(playbackVM.position, 0, accuracy: 0.01)

        // Nudge forward by 10 seconds using positive delta
        playbackVM.nudge(by: 10)
        XCTAssertEqual(playbackVM.position, 10, accuracy: 0.01)

        // Nudge backward by 5 seconds using negative delta, expect 5 seconds now
        playbackVM.nudge(by: -5)
        XCTAssertEqual(playbackVM.position, 5, accuracy: 0.01)

        // Nudge backward by 10 seconds from 5, should clamp to 0
        playbackVM.nudge(by: -10)
        XCTAssertEqual(playbackVM.position, 0, accuracy: 0.01)

        // Nudge forward beyond duration, should clamp to duration
        playbackVM.nudge(by: 200)
        XCTAssertEqual(playbackVM.position, playbackVM.duration, accuracy: 0.01)
    }

    func testNudgeRepeatedCalls() throws {
        guard let fileURL = testFileURL else {
            XCTFail("Test audio file URL not found.")
            return
        }

        let fileInfo = RecordingFileInfo(
            url: fileURL,
            name: "test_audio.m4a",
            size: 123456,
            created: Date(),
            duration: 50.0
        )
        playbackVM.load(file: fileInfo)

        var expectedPosition: TimeInterval = 0
        playbackVM.seek(to: expectedPosition)
        XCTAssertEqual(playbackVM.position, expectedPosition, accuracy: 0.01)

        let steps = [10, 10, -5, 10, -30, 60, -100]  // in seconds
        for step in steps {
            let nudgedPosition = expectedPosition + Double(step)
            // Clamp to bounds
            expectedPosition = max(0, min(nudgedPosition, playbackVM.duration))
            playbackVM.nudge(by: Double(step))
            XCTAssertEqual(playbackVM.position, expectedPosition, accuracy: 0.01)
        }
    }
}
