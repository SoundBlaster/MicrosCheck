//
//  PlaybackViewUITests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2025-08-19.
//

import XCTest

final class PlaybackViewUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testPlaybackViewUIElementsExist() throws {
        // Navigate to a state where PlaybackView is visible
        // For this test, assume the app launches with PlaybackView visible for a loaded file
        let fileNameText = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@", ".m4a")
        ).firstMatch
        XCTAssertTrue(
            fileNameText.waitForExistence(timeout: 5), "Playback file name should be visible")

        let playPauseButton = app.buttons.matching(identifier: "play.circle.fill").firstMatch
        XCTAssertTrue(
            playPauseButton.exists
                || app.buttons.matching(identifier: "pause.circle.fill").firstMatch.exists,
            "Play/Pause button should exist")

        let rewindButton = app.buttons["gobackward.10"]
        let forwardButton = app.buttons["goforward.10"]
        XCTAssertTrue(rewindButton.exists, "Rewind 10s button should exist")
        XCTAssertTrue(forwardButton.exists, "Forward 10s button should exist")

        let progressBar = app.progressIndicators.firstMatch
        XCTAssertTrue(progressBar.exists, "Progress bar should exist")

        let rateSlider = app.sliders["Playback Rate"]
        let pitchSlider = app.sliders["Pitch (cents)"]
        XCTAssertTrue(rateSlider.exists, "Playback Rate slider should exist")
        XCTAssertTrue(pitchSlider.exists, "Pitch slider should exist")

        let masterVolumeSlider = app.sliders["Master Volume"]
        let leftGainSlider = app.sliders["Left Channel Gain (dB)"]
        let rightGainSlider = app.sliders["Right Channel Gain (dB)"]
        XCTAssertTrue(masterVolumeSlider.exists, "Master Volume slider should exist")
        XCTAssertTrue(leftGainSlider.exists, "Left Channel Gain slider should exist")
        XCTAssertTrue(rightGainSlider.exists, "Right Channel Gain slider should exist")

        let aPointButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Set A")
        ).firstMatch
        XCTAssertTrue(aPointButton.exists, "A-B loop Set A button should exist")
    }

    func testPlayPauseStopButtons() throws {
        let playPauseButton = app.buttons.matching(identifier: "play.circle.fill").firstMatch

        if playPauseButton.exists {
            playPauseButton.tap()
            // After play, pause button should appear
            let pauseButton = app.buttons["pause.circle.fill"]
            XCTAssertTrue(
                pauseButton.waitForExistence(timeout: 2), "Pause button should appear after play")
            pauseButton.tap()
            XCTAssertTrue(
                playPauseButton.waitForExistence(timeout: 2),
                "Play button should reappear after pause")
        }
    }

    func testSeekButtons() throws {
        let rewindButton = app.buttons["gobackward.10"]
        let forwardButton = app.buttons["goforward.10"]

        XCTAssertTrue(rewindButton.exists)
        XCTAssertTrue(forwardButton.exists)

        rewindButton.tap()
        forwardButton.tap()
        // No crash expected, UI remains responsive
    }

    func testDPCSliders() throws {
        let rateSlider = app.sliders["Playback Rate"]
        let pitchSlider = app.sliders["Pitch (cents)"]

        XCTAssertTrue(rateSlider.exists)
        XCTAssertTrue(pitchSlider.exists)

        rateSlider.adjust(toNormalizedSliderPosition: 0.75)
        pitchSlider.adjust(toNormalizedSliderPosition: 0.5)
    }

    func testVolumeSliders() throws {
        let masterVolumeSlider = app.sliders["Master Volume"]
        let leftGainSlider = app.sliders["Left Channel Gain (dB)"]
        let rightGainSlider = app.sliders["Right Channel Gain (dB)"]

        XCTAssertTrue(masterVolumeSlider.exists)
        XCTAssertTrue(leftGainSlider.exists)
        XCTAssertTrue(rightGainSlider.exists)

        masterVolumeSlider.adjust(toNormalizedSliderPosition: 0.5)
        leftGainSlider.adjust(toNormalizedSliderPosition: 0.25)
        rightGainSlider.adjust(toNormalizedSliderPosition: 0.75)
    }

    func testABLoopButton() throws {
        let setAButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Set A"))
            .firstMatch
        XCTAssertTrue(setAButton.exists)
        setAButton.tap()

        let setBButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Set B"))
            .firstMatch
        XCTAssertTrue(setBButton.exists)
        setBButton.tap()

        let clearLoopButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Clear Loop")
        ).firstMatch
        XCTAssertTrue(clearLoopButton.exists)
        clearLoopButton.tap()
    }
}
