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

    var sut: PlantController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        sut = PlantController()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
    }

    /// Tests if location strings are properly stripped of whitespaces
    func testTrimmingLocation() throws {
        
        let location = " Kitchen  ".trimmingCharacters(in: .whitespacesAndNewlines)
        
        let result = "Kitchen"
        
        XCTAssertEqual(location, result, "Location still contains whitespaces")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
