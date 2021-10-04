//
//  DataProvider.swift
//  DataProvider
//
//  Created by Adam on 9/2/21.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), items: [.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), items: loadItems())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: Date(), items: loadItems())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    func loadItems() -> [Item] {
        let persistenceController = PersistenceController()
        let itemRequest = persistenceController.fetchRequestForTopItems(count: 5)
        return persistenceController.results(for: itemRequest)
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [Item]

    static let example = SimpleEntry(date: Date(), items: previewItems)
    static let previewItems: [Item] = {
        let persistenceController = PersistenceController.preview
        let itemRequest = persistenceController.fetchRequestForTopItems(count: 5)
        return persistenceController.results(for: itemRequest)
    }()
}
