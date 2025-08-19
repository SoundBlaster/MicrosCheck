//
//  PlaybackViewModelTests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2025-08-19.
//

import AVFoundation
import XCTest

@testable import MicrosCheck

final class PlaybackViewModelTests: XCTestCase {

    var viewModel: PlaybackViewModel!
    var testFileURL: URL!

    override func setUpWithError() throws {
        viewModel = PlaybackViewModel()
        // Use a dummy audio file URL for testing
        testFileURL =
            Bundle.module.url(forResource: "test_audio", withExtension: "m4a")
            ?? URL(fileURLWithPath: "/tmp/test_audio.m4a")
    }

    override func tearDownWithError() throws {
        viewModel = nil
        testFileURL = nil
    }

    func testInitialState() throws {
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertEqual(viewModel.duration, 0)
        XCTAssertEqual(viewModel.position, 0)
        XCTAssertEqual(viewModel.leftLevel, -60)
        XCTAssertEqual(viewModel.rightLevel, -60)
        XCTAssertNil(viewModel.currentFile)
        XCTAssertEqual(viewModel.rate, 1.0)
        XCTAssertEqual(viewModel.pitchCents, 0.0)
        XCTAssertEqual(viewModel.masterVolume, 1.0)
        XCTAssertEqual(viewModel.volumeL, 0.0)
        XCTAssertEqual(viewModel.volumeR, 0.0)
        XCTAssertNil(viewModel.aPoint)
        XCTAssertNil(viewModel.bPoint)
    }

    func testLoadFile() throws {
        let fileInfo = RecordingFileInfo(
            url: testFileURL, name: "test_audio.m4a", size: 123456, created: Date(), duration: 10)
        viewModel.load(file: fileInfo)
        XCTAssertEqual(viewModel.currentFile?.name, "test_audio.m4a")
        XCTAssertGreaterThan(viewModel.duration, 0)
        XCTAssertEqual(viewModel.position, 0)
        XCTAssertFalse(viewModel.isPlaying)
    }

    func testPlayPauseStop() throws {
        let fileInfo = RecordingFileInfo(
            url: testFileURL, name: "test_audio.m4a", size: 123456, created: Date(), duration: 10)
        viewModel.load(file: fileInfo)

        viewModel.play()
        XCTAssertTrue(viewModel.isPlaying)

        viewModel.pause()
        XCTAssertFalse(viewModel.isPlaying)

        viewModel.play()
        XCTAssertTrue(viewModel.isPlaying)

        viewModel.stop()
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertEqual(viewModel.position, 0)
    }

    func testSeekAndNudge() throws {
        let fileInfo = RecordingFileInfo(
            url: testFileURL, name: "test_audio.m4a", size: 123456, created: Date(), duration: 10)
        viewModel.load(file: fileInfo)

        viewModel.seek(to: 5)
        XCTAssertEqual(viewModel.position, 5, accuracy: 0.1)

        viewModel.nudge(by: 2)
        XCTAssertEqual(viewModel.position, 7, accuracy: 0.1)

        viewModel.nudge(by: -3)
        XCTAssertEqual(viewModel.position, 4, accuracy: 0.1)

        // Seek beyond duration clamps to duration
        viewModel.seek(to: 20)
        XCTAssertLessThanOrEqual(viewModel.position, viewModel.duration)

        // Seek below 0 clamps to 0
        viewModel.seek(to: -5)
        XCTAssertGreaterThanOrEqual(viewModel.position, 0)
    }

    func testDPCRatePitchChange() throws {
        viewModel.rate = 1.5
        XCTAssertEqual(viewModel.rate, 1.5)

        viewModel.pitchCents = 600
        XCTAssertEqual(viewModel.pitchCents, 600)

        viewModel.rate = 0.75
        XCTAssertEqual(viewModel.rate, 0.75)

        viewModel.pitchCents = -600
        XCTAssertEqual(viewModel.pitchCents, -600)
    }

    func testVolumeControlChange() throws {
        viewModel.masterVolume = 0.5
        XCTAssertEqual(viewModel.masterVolume, 0.5)

        viewModel.volumeL = -10
        XCTAssertEqual(viewModel.volumeL, -10)

        viewModel.volumeR = 10
        XCTAssertEqual(viewModel.volumeR, 10)
    }

    func testABLoopBehavior() throws {
        let fileInfo = RecordingFileInfo(
            url: testFileURL, name: "test_audio.m4a", size: 123456, created: Date(), duration: 10)
        viewModel.load(file: fileInfo)

        // Set A and B points
        viewModel.aPoint = 2
        viewModel.bPoint = 5

        // Seek before A clamps to A
        viewModel.seek(to: 1)
        XCTAssertEqual(viewModel.position, 2, accuracy: 0.1)

        // Seek after B clamps to B
        viewModel.seek(to: 6)
        XCTAssertEqual(viewModel.position, 5, accuracy: 0.1)

        // Simulate playback position reaching B triggers loop back to A
        viewModel.position = 5
        // Manually invoke updateProgress to simulate timer tick
        viewModel.updateProgress()
        XCTAssertEqual(viewModel.position, 2, accuracy: 0.1)
    }
}
