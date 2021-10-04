//
//  AssetTest.swift
//  AssetTest
//
//  Created by Adam on 8/16/21.
//

import XCTest
@testable import Peanut

class AssetTests: XCTestCase {
    func testColorsExist() {
        for color in Project.awardsColors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }

    func testJSONLoadsCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
}
