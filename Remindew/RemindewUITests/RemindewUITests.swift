//
//  RemindewUITests.swift
//  RemindewUITests
//
//  Created by Jorge Alvarez on 11/19/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import XCTest

class RemindewUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
//        app/*@START_MENU_TOKEN@*/.staticTexts["Mon"]/*[[".buttons[\"Mon\"].staticTexts[\"Mon\"]",".staticTexts[\"Mon\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app/*@START_MENU_TOKEN@*/.staticTexts["Wed"]/*[[".buttons[\"Wed\"].staticTexts[\"Wed\"]",".staticTexts[\"Wed\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app/*@START_MENU_TOKEN@*/.staticTexts["Fri"]/*[[".buttons[\"Fri\"].staticTexts[\"Fri\"]",".staticTexts[\"Fri\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.datePickers/*@START_MENU_TOKEN@*/.pickerWheels["8 o’clock"].press(forDuration: 0.7);/*[[".pickers.pickerWheels[\"8 o’clock\"]",".tap()",".press(forDuration: 0.7);",".pickerWheels[\"8 o’clock\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
//        app.buttons["Add Plant"].tap()
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
