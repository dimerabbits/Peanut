//
//  PeanutUITests.swift
//  PeanutUITests
//
//  Created by Adam on 8/31/21.
//

import XCTest

class PeanutUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    func testAppHas5Tabs() {
        XCTAssertEqual(app.tabBars.buttons.count, 5, "There should be 5 tabs in the app.")
    }

    func testOpenTabAddsProjects() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

        for tapCount in 1...3 {
            app.buttons["Add Project"].tap()
            XCTAssertEqual(app.tables.cells.count, tapCount, "There should be \(tapCount) list row(s).")
        }
    }

    func testAddingItemInsertsRows() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")

        app.buttons["Add New Item"].tap()
        XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list row after adding an Item.")
    }

    func testEditingProjectUpdatesCorrectly() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")

        app.buttons["Edit project"].tap()

        let textField = app.textFields["Project name"].firstMatch
        textField.tap()
        textField.typeText(" 2")
        app.buttons["Return"].tap()

        app.buttons["Open Projects"].tap()
        XCTAssertTrue(app.tables.staticTexts["NEW PROJECT 2"].exists,
                      "The new project name should be visible in the list.")
    }

    func testEditingItemUpdatesCorrectly() {
        // Go to "Open" and add one project and one item before the test.
        testAddingItemInsertsRows()

        app.buttons["New Item"].tap()

        let textField = app.textFields["Item name"].firstMatch
        textField.tap()
        textField.typeText(" 2")
        app.buttons["next"].tap()

        app.buttons["Open Projects"].tap()

        XCTAssertTrue(app.buttons["New Item 2"].exists,
                      "The new item name should be visible in the list.")
    }

    func testAllAwarsShowLockedAlert() {
        app.buttons["Awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()

            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }
}
