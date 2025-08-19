//
//  QA2_UI_Tests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2024-06-12.
//

import XCTest

final class QA2_UI_Tests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Basic UI Tests

    func testInitialUIElementsExist() throws {
        // Verify key UI elements are present on launch
        XCTAssertTrue(
            app.buttons["Record"].waitForExistence(timeout: 5), "Record button must exist")
        XCTAssertTrue(app.buttons["Stop"].exists, "Stop button must exist")
        XCTAssertTrue(app.staticTexts["Recordings"].exists, "Recordings label must exist")
        XCTAssertTrue(
            app.otherElements["LiveWaveformView"].exists, "Live waveform visualization must exist")
    }

    func testRecordPauseStopFlow() throws {
        let recordButton = app.buttons["Record"]
        let pauseButton = app.buttons["Pause"]
        let stopButton = app.buttons["Stop"]

        // Start recording
        XCTAssertTrue(recordButton.exists)
        recordButton.tap()

        // After tapping Record, the label should switch to Pause
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 1.0))
        XCTAssertFalse(recordButton.exists)

        // Pause recording
        pauseButton.tap()

        // After pause, Record button should reappear
        XCTAssertTrue(recordButton.waitForExistence(timeout: 1.0))
        XCTAssertFalse(pauseButton.exists)

        // Resume recording
        recordButton.tap()
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 1.0))

        // Stop recording
        stopButton.tap()

        // After stop, Record button should be visible again
        XCTAssertTrue(recordButton.waitForExistence(timeout: 1.0))
        XCTAssertFalse(pauseButton.exists)
    }

    func testPlaybackControlsExist() throws {
        // Await or select a recording file to enable playback controls
        let fileList = app.tables.firstMatch
        XCTAssertTrue(fileList.waitForExistence(timeout: 5), "File list must exist")

        if fileList.cells.count > 0 {
            // Select first file to load playback view
            fileList.cells.element(boundBy: 0).tap()

            // Check play/pause button presence
            let playButton = app.buttons.matching(identifier: "play.circle.fill").firstMatch
            let pauseButton = app.buttons.matching(identifier: "pause.circle.fill").firstMatch

            XCTAssertTrue(
                playButton.exists || pauseButton.exists, "Play/Pause button must exist"
            )

            // Check seek buttons
            XCTAssertTrue(app.buttons["gobackward.10"].exists, "Rewind 10s button must exist")
            XCTAssertTrue(app.buttons["goforward.10"].exists, "Forward 10s button must exist")
        }
    }

    func testSearchFilterPanel() throws {
        let searchField = app.textFields["Search recordings"]
        XCTAssertTrue(searchField.exists, "Search field must exist")

        searchField.tap()
        searchField.typeText("test")
        // Wait for debounce
        sleep(1)

        // Clear search
        let clearButton = app.buttons["Clear search text"]
        if clearButton.exists {
            clearButton.tap()
        }
    }

    func testLockUnlockUI() throws {
        let lockButton = app.buttons.matching(identifier: "Lock UI").firstMatch
        if lockButton.exists {
            lockButton.tap()
            // UI should be disabled except lock button

            let recordButton = app.buttons["Record"]
            XCTAssertFalse(recordButton.isEnabled, "Record button should be disabled when locked")

            // Unlock by simulating long press gesture on unlock overlay
            let unlockText = app.staticTexts["Hold to unlock"]
            if unlockText.exists {
                unlockText.press(forDuration: 2.1)
                XCTAssertTrue(
                    recordButton.isEnabled, "Record button should be enabled after unlock")
            }
        }
    }

    // MARK: - Placeholder for QA3 Stress and Endurance Tests

    func testStressRecordingStartStopRepeatedly() throws {
        // This test is a placeholder for automated stress testing
        // Repeatedly start and stop recording to check app stability

        let recordButton = app.buttons["Record"]
        let stopButton = app.buttons["Stop"]

        for _ in 0..<10 {
            recordButton.tap()
            sleep(1)
            stopButton.tap()
            sleep(1)
        }
    }
}
