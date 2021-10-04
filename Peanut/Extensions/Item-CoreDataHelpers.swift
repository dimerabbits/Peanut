//
//  Item-CoreDataHelpers.swift
//  Item-CoreDataHelpers
//
//  Created by Adam on 8/31/21.
//

import Foundation

extension Item {

    enum SortOrder {
        case optimized
        case title
        case creationDate
    }

    var itemTitle: String { title ?? NSLocalizedString("New Item", comment: "Create a new item") }

    var itemDetail: String { detail ?? "" }

    var itemNote: String { note ?? "" }

    var itemCreationDate: Date { creationDate ?? Date() }

    static var example: Item {
        let controller = PersistenceController.preview
        let viewContext = controller.container.viewContext

        let item = Item(context: viewContext)
        item.title = "Example Item"
        item.detail = "This is an example item"
        item.priority = 3
        item.creationDate = Date()

        return item
    }
}
