//
//  PerformanceTests.swift
//  PerformanceTests
//
//  Created by Adam on 8/16/21.
//

import XCTest
@testable import Peanut

class PerformanceTests: BaseTestCase {
    func test_AwardCalculationPerformance() throws {
        // Create a lot of data to measure against
        for _ in 1...100 {
            try persistenceController.createSampleData()
        }

        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change this if you add awards.")

        measure {
            _ = awards.filter(persistenceController.hasEarned)
        }
    }
}
