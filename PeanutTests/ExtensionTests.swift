//
//  ExtensionTests.swift
//  ExtensionTests
//
//  Created by Adam on 8/16/21.
//

import SwiftUI
import XCTest
@testable import Peanut

class ExtensionTests: XCTestCase {

    func test_SequenceKeyPathSortingSelf() {
        let items = [1, 4, 3, 2, 5]
        let sortedItems = items.sorted(by: \.self)
        XCTAssertEqual(sortedItems, [1, 2, 3, 4, 5], "The sorted numbers must be ascending order.")
    }

    func test_SequenceKeyPathSortingCustom() {
        let cal = Calendar.autoupdatingCurrent
        let dayComponents = DateComponents(day: 1)
        let now = Date()
        struct Example: Equatable {
            let value: Date
        }

        let example1 = Example(value: cal.date(byAdding: dayComponents, to: now)!)
        let example2 = Example(value: cal.date(byAdding: dayComponents, to: example1.value)!)
        let example3 = Example(value: cal.date(byAdding: dayComponents, to: example2.value)!)
        let array = [example1, example2, example3]

        let sortedItems = array.sorted(by: \.value) {
            $0 > $1
        }

        XCTAssertEqual(sortedItems, [example3, example2, example1])
    }

    func test_BundleDecodingAwards() {
        let awards = Bundle.main.decode([Award].self, from: "Awards.json")
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to a non-empty array.")
    }

    func test_DecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode(String.self, from: "DecodableString.json")
        XCTAssertEqual(data, "Testing the extension's ability to load the simplest kind of JSON – just one value.")
    }

    func test_DecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode([String: Int].self, from: "DecodableDictionary.json")
        XCTAssertEqual(data.count, 3)
        XCTAssertEqual(data["One"], 1)
    }

    func test_BindingOnChangeCallsFunction() {
        // Given
        var onChangeFunctionRun = false
        func exampleFunctionToCall() {
            onChangeFunctionRun = true
        }

        var storedValue = ""
        let binding = Binding(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let changedBinding = binding.onChange(exampleFunctionToCall)

        // When
        changedBinding.wrappedValue = "Test"

        // Then
        XCTAssertTrue(onChangeFunctionRun, "The onChange() function was not run.")
    }
}
