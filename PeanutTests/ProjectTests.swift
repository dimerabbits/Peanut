//
//  ProjectTests.swift
//  ProjectTests
//
//  Created by Adam on 8/16/21.
//

import CoreData
import XCTest
@testable import Peanut

class ProjectTests: BaseTestCase {

    func test_creatingProjectsAndItems() {
        let targetCount = 10
        for _ in 0..<targetCount {
            let project = Project(context: managedObjectContext)

            for _ in 0..<targetCount {
                let item = Item(context: managedObjectContext)
                item.project = project
            }
        }

        XCTAssertEqual(persistenceController.count(for: Project.fetchRequest()), targetCount)
        XCTAssertEqual(persistenceController.count(for: Item.fetchRequest()), targetCount * targetCount)
    }

    // Create sample data, fetch all the projects, delete the first one of them,
    // then assert that we have 4 projects and 40 items remaining.
    func test_deletingProjectCascadeDeletesItems() throws {
        try persistenceController.createSampleData()
        let request = NSFetchRequest<Project>(entityName: "Project")
        let projects = try managedObjectContext.fetch(request)
        XCTAssertEqual(projects.count, 5)

        persistenceController.delete(projects[0])
        XCTAssertEqual(persistenceController.count(for: Project.fetchRequest()), 4)
        XCTAssertEqual(persistenceController.count(for: Item.fetchRequest()), 40)
    }
}
