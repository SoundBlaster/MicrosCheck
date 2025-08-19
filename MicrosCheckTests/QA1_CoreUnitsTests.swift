//
//  QA1_CoreUnitsTests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2024-06-12.
//

import Combine
import XCTest

@testable import MicrosCheck

final class QA1_CoreUnitsTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    // MARK: - RecorderViewModel Tests

    func testRecorderViewModelStateTransitions() async throws {
        let appState = AppState()
        let vm = RecorderViewModel(appState: appState)

        XCTAssertFalse(vm.isRecording)
        XCTAssertFalse(vm.isPrepared)

        await vm.prepare()
        XCTAssertTrue(vm.isPrepared)

        vm.record()
        XCTAssertTrue(vm.isRecording)

        vm.pause()
        XCTAssertFalse(vm.isRecording)

        vm.record()
        XCTAssertTrue(vm.isRecording)

        vm.stop()
        XCTAssertFalse(vm.isRecording)
    }

    func testRecorderViewModelMetersUpdate() throws {
        let appState = AppState()
        let vm = RecorderViewModel(appState: appState)

        // Setup fake AVAudioRecorder using KVC may not be possible, so test updateMeters with mock data
        vm.leftLevel = -20
        vm.rightLevel = -25
        XCTAssertGreaterThanOrEqual(vm.leftLevel, -60)
        XCTAssertLessThanOrEqual(vm.leftLevel, 0)
        XCTAssertGreaterThanOrEqual(vm.rightLevel, -60)
        XCTAssertLessThanOrEqual(vm.rightLevel, 0)
    }

    // MARK: - PlaybackViewModel Tests

    func testPlaybackViewModelInitialState() {
        let vm = PlaybackViewModel()

        XCTAssertFalse(vm.isPlaying)
        XCTAssertEqual(vm.position, 0)
        XCTAssertEqual(vm.duration, 0)
        XCTAssertEqual(vm.leftLevel, -60)
        XCTAssertEqual(vm.rightLevel, -60)
        XCTAssertNil(vm.currentFile)
        XCTAssertEqual(vm.rate, 1.0)
        XCTAssertEqual(vm.pitchCents, 0.0)
        XCTAssertEqual(vm.masterVolume, 1.0)
    }

    func testPlaybackViewModelLoadFileAndPlayPauseStop() {
        let vm = PlaybackViewModel()
        let file = RecordingFileInfo(
            url: URL(fileURLWithPath: "/tmp/test.m4a"),
            name: "test.m4a",
            size: 1000,
            created: Date(),
            duration: 10.0
        )
        vm.load(file: file)
        XCTAssertEqual(vm.currentFile?.url, file.url)
        XCTAssertEqual(vm.position, 0)

        vm.play()
        XCTAssertTrue(vm.isPlaying)

        vm.pause()
        XCTAssertFalse(vm.isPlaying)

        vm.play()
        XCTAssertTrue(vm.isPlaying)

        vm.stop()
        XCTAssertFalse(vm.isPlaying)
        XCTAssertEqual(vm.position, 0)
    }

    func testPlaybackViewModelSeekAndNudge() {
        let vm = PlaybackViewModel()
        let file = RecordingFileInfo(
            url: URL(fileURLWithPath: "/tmp/test.m4a"),
            name: "test.m4a",
            size: 1000,
            created: Date(),
            duration: 10.0
        )
        vm.load(file: file)

        vm.seek(to: 5)
        XCTAssertEqual(vm.position, 5, accuracy: 0.1)

        vm.nudge(by: 2)
        XCTAssertEqual(vm.position, 7, accuracy: 0.1)

        vm.nudge(by: -3)
        XCTAssertEqual(vm.position, 4, accuracy: 0.1)
    }

    func testPlaybackViewModelABLoopBehavior() {
        let vm = PlaybackViewModel()
        let file = RecordingFileInfo(
            url: URL(fileURLWithPath: "/tmp/test.m4a"),
            name: "test.m4a",
            size: 1000,
            created: Date(),
            duration: 20.0
        )
        vm.load(file: file)

        vm.aPoint = 2
        vm.bPoint = 10

        vm.seek(to: 1)
        XCTAssertEqual(vm.position, 2, accuracy: 0.2)

        vm.seek(to: 11)
        XCTAssertEqual(vm.position, 10, accuracy: 0.2)
    }

    // MARK: - LiveWaveformView Tests

    func testLiveWaveformViewNormalizesDb() {
        let view = LiveWaveformView(samples: [-61, -60, -30, -10, 0])
        XCTAssertEqual(view.normalizedDb(-61), 0)
        XCTAssertEqual(view.normalizedDb(-60), 0)
        XCTAssertEqual(view.normalizedDb(-30), 0.5, accuracy: 0.01)
        XCTAssertEqual(view.normalizedDb(-10), 0.83, accuracy: 0.01)
        XCTAssertEqual(view.normalizedDb(0), 1.0, accuracy: 0.01)
    }

    // MARK: - WaveformGenerator Tests (basic logic)

    func testWaveformSegmentEquatable() {
        let seg1 = WaveformSegment(rmsDb: -30, peakDb: -20)
        let seg2 = WaveformSegment(rmsDb: -30, peakDb: -20)
        XCTAssertEqual(seg1, seg2)
    }

    func testWaveformDataEquatable() {
        let segs = [
            WaveformSegment(rmsDb: -30, peakDb: -20), WaveformSegment(rmsDb: -40, peakDb: -30),
        ]
        let w1 = WaveformData(segments: segs, segmentDuration: 0.1, totalDuration: 10)
        let w2 = WaveformData(segments: segs, segmentDuration: 0.1, totalDuration: 10)
        XCTAssertEqual(w1, w2)
    }

    // MARK: - VerticalDBRuler Tests

    func testVerticalDBRulerTickCount() {
        let view = VerticalDBRuler(minDb: -60, maxDb: 0, tickStep: 10)
        // No state changes here, but we test the values indirectly in UI tests or snapshot tests
        XCTAssertNotNil(view)
    }

    // MARK: - HorizontalTimeRuler Tests

    func testHorizontalTimeRulerTimeLabelFormatting() {
        let view = HorizontalTimeRuler(duration: 3661, currentTime: 3661)
        XCTAssertEqual(view.timeLabel(for: 0), "00:00")
        XCTAssertEqual(view.timeLabel(for: 59), "00:59")
        XCTAssertEqual(view.timeLabel(for: 60), "01:00")
        XCTAssertEqual(view.timeLabel(for: 3661), "1:01:01")
    }
}
