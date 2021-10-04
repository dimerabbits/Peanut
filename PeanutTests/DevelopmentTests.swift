//
//  DevelopmentTests.swift
//  DevelopmentTests
//
//  Created by Adam on 8/16/21.
//
// swiftlint:disable line_length

import CoreData
import XCTest
@testable import Peanut

class DevelopmentTests: BaseTestCase {
    func test_sampleDataCreationWorks() throws {
        try persistenceController.createSampleData()

        XCTAssertEqual(persistenceController.count(for: Project.fetchRequest()), 5, "There should be 5 sample projects.")
        XCTAssertEqual(persistenceController.count(for: Item.fetchRequest()), 50, "There should be 50 sample items.")
    }

    func test_deleteAllClearsEverything() throws {
        try persistenceController.createSampleData()

        persistenceController.deleteAll()

        XCTAssertEqual(persistenceController.count(for: Project.fetchRequest()), 0, "deleteAll() should be no projects.")
        XCTAssertEqual(persistenceController.count(for: Item.fetchRequest()), 0, "deleteAll() should be no items.")
    }

    func test_exampleProjectIsClosed() {
        let project = Project.example
        XCTAssertTrue(project.closed, "The example project should be closed.")
    }

    func test_exampleItemIsHighPriority() {
        let item = Item.example
        XCTAssertEqual(item.priority, 3, "The example item should be high priority.")
    }
}
