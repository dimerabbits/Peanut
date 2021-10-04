//
//  PeanutTests.swift
//  PeanutTests
//
//  Created by Adam on 8/31/21.
//

import CoreData
import XCTest
@testable import Peanut

class BaseTestCase: XCTestCase {
    var persistenceController: PersistenceController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        managedObjectContext = persistenceController.container.viewContext
    }
}
