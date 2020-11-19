//
//  RemindewTests.swift
//  RemindewTests
//
//  Created by Jorge Alvarez on 11/19/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import XCTest
@testable import Remindew

class RemindewTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let testPlant = Plant(nickname: "bob", species: "palm", water_schedule: Date(), frequency: Int16(5))
        XCTAssertEqual(testPlant.nickname, "bob", "Failed plant nickname test")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
