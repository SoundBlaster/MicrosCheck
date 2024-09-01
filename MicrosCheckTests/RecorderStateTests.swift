//
//  ReccorderStateTests.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 18.06.2023.
//

import XCTest

@testable import MicrosCheck 

final class RecorderStateTests: XCTestCase {

    var recorderState: RecorderImpl.StateHolder?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        recorderState = RecorderImpl.StateHolder()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        recorderState = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        XCTAssertNotNil(recorderState)
        
        guard let recorderState else {
            XCTFail()
            return
        }
        
        var state = recorderState.state
        XCTAssertEqual(state, .inited)

        state = try recorderState.updateState(to: .prepared)
        XCTAssertEqual(state, .prepared)
        
        state = try recorderState.updateState(to: .recording)
        XCTAssertEqual(state, .recording)
        
        state = try recorderState.updateState(to: .paused)
        XCTAssertEqual(state, .paused)
        
        state = try recorderState.updateState(to: .stopped)
        XCTAssertEqual(state, .stopped)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
