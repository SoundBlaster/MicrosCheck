//
//  RecorderMainScreenUITests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2025-08-19.
//

import XCTest

final class RecorderMainScreenUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testInitialUIElementsExist() throws {
        // Check that main UI elements exist on launch
        XCTAssertTrue(app.staticTexts["Ready"].exists)
        XCTAssertTrue(app.buttons["Record"].exists)
        XCTAssertTrue(app.buttons["Stop"].exists)
        XCTAssertTrue(app.staticTexts["Recordings"].exists)
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

    func testLockOverlayBlocksUI() throws {
        // Assuming the lock overlay is initially off
        // Lock the UI by tapping the lock button (bottom left)
        let lockButton = app.buttons["Lock Button"]
        if lockButton.exists {
            lockButton.tap()
            // UI should be blocked, so Record button should be disabled
            let recordButton = app.buttons["Record"]
            XCTAssertFalse(recordButton.isEnabled)

            // Unlock by long-pressing the unlock gesture area (simulate)
            let unlockText = app.staticTexts["Hold to unlock"]
            if unlockText.exists {
                unlockText.press(forDuration: 2.1)
                // After unlock, Record button should be enabled
                XCTAssertTrue(recordButton.isEnabled)
            }
        }
    }
}
