//
//  RecorderViewModelInputTests.swift
//  MicrosCheckTests
//
//  Created by Egor Merkushev on 2025-08-19.
//

import XCTest

@testable import MicrosCheck

final class RecorderViewModelInputTests: XCTestCase {

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

    func testAvailableInputsPopulated() throws {
        // Initially, available inputs should be loaded from recorder
        let inputs = viewModel.availableInputs
        XCTAssertFalse(inputs.isEmpty, "Available inputs should not be empty")
        XCTAssertTrue(
            inputs.contains(where: { $0.lowercased().contains("mic") }),
            "Available inputs should contain microphone names")
    }

    func testSelectInputUpdatesAppState() async throws {
        // Select a valid input name
        let inputs = viewModel.availableInputs
        guard let firstInput = inputs.first else {
            XCTFail("No inputs available")
            return
        }

        await viewModel.selectInput(name: firstInput)
        XCTAssertEqual(viewModel.selectedInputName, firstInput)
        XCTAssertEqual(appState.selectedInputName, firstInput)
    }

    func testSelectInputWithInvalidNameDoesNotChangeSelection() async throws {
        let invalidName = "NonExistentInput"
        let oldSelection = viewModel.selectedInputName

        await viewModel.selectInput(name: invalidName)
        // Selection should remain unchanged
        XCTAssertEqual(viewModel.selectedInputName, oldSelection)
        XCTAssertEqual(appState.selectedInputName, oldSelection)
    }

    func testSelectingNotSelectedInputNameDoesNothing() async throws {
        let oldSelection = viewModel.selectedInputName

        await viewModel.selectInput(name: .notSelectedInputName)
        // Selection should remain unchanged
        XCTAssertEqual(viewModel.selectedInputName, oldSelection)
        XCTAssertEqual(appState.selectedInputName, oldSelection)
    }
}
