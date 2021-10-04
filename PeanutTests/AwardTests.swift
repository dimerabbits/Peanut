//
//  AwardTests.swift
//  AwardTests
//
//  Created by Adam on 8/16/21.
//

import CoreData
import XCTest
@testable import Peanut

class AwardTests: BaseTestCase {
    let awards = Award.allAwards

    func test_awardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
        }
    }

    func test_NoAwards() {
        for award in awards {
            XCTAssertFalse(persistenceController.hasEarned(award: award), "New users should have no earned awards.")
        }
    }

    func test_itemAwards() throws {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {

            for _ in 0..<value {
                _ = Item(context: managedObjectContext)
            }

            let matches = awards.filter { award in
                award.criterion == "items" && persistenceController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Adding \(value) items should unlock \(count + 1) awards.")

            persistenceController.deleteAll()
        }
    }

    func test_completedAwards() throws {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {

            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                item.completed = true
            }

            let matches = awards.filter { award in
                award.criterion == "complete" && persistenceController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Completing \(value) items should unlock \(count + 1) awards.")

            persistenceController.deleteAll()
        }
    }
}
