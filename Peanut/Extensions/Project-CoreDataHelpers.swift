//
//  Project-CoreDataHelpers.swift
//  Peanut
//
//  Created by Adam on 8/31/21.
//

import SwiftUI
import CloudKit

extension Project {

    var projectTitle: String { title ?? NSLocalizedString("New Project", comment: "Create a new project") }

    var projectDetail: String { detail ?? "" }

    var projectColor: String { color ?? Project.defaultColor }

    var projectNote: String { note ?? "" }

    var projectCreationDate: Date { creationDate ?? Date() }

    var projectItems: [Item] { items?.allObjects as? [Item] ?? [] }

    var projectItemsDefaultSorted: [Item] {
        projectItems.sorted { first, second in
            if first.completed == false {
                if second.completed == true {
                    return true
                }
            } else if first.completed == true {
                if second.completed == false {
                    return false
                }
            }

            if first.priority > second.priority {
                return true
            } else if first.priority < second.priority {
                return false
            }

            return first.itemCreationDate < second.itemCreationDate
        }
    }

    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? []
        guard originalItems.isEmpty == false else { return 0 }

        let completedItems = originalItems.filter(\.completed)
        return Double(completedItems.count) / Double(originalItems.count)
    }

    var label: LocalizedStringKey {
        LocalizedStringKey(
            "\(projectTitle), \(projectItems.count) items,\(completionAmount * 100, specifier: "%g")% complete."
        )
    }

    static var example: Project {
        let controller = PersistenceController.preview
        let viewContext = controller.container.viewContext

        let project = Project(context: viewContext)
        project.title = "Example Project"
        project.detail = "This is an example project"
        project.closed = true
        project.creationDate = Date()
        return project
    }

    func projectItems(using sortOrder: Item.SortOrder) -> [Item] {
        switch sortOrder {
        case .title:
            return projectItems.sorted(by: \Item.itemTitle)
        case .creationDate:
            return projectItems.sorted(by: \Item.itemCreationDate)
        case .optimized:
            return projectItemsDefaultSorted
        }
    }

    // MARK: - Interacting With CloudKit Directly

    func prepareCloudRecords(owner: String) -> [CKRecord] {
        let parentName = objectID.uriRepresentation().absoluteString
        let parentID = CKRecord.ID(recordName: parentName)
        let parent = CKRecord(recordType: "Project", recordID: parentID)
        parent["title"] = projectTitle
        parent["detail"] = projectDetail
        parent["owner"] = owner
        parent["closed"] = closed

        var records = projectItemsDefaultSorted.map { item -> CKRecord in
            let childName = item.objectID.uriRepresentation().absoluteString
            let childID = CKRecord.ID(recordName: childName)
            let child = CKRecord(recordType: "Item", recordID: childID)
            child["title"] = item.itemTitle
            child["detail"] = item.itemDetail
            child["completed"] = item.completed
            child["project"] = CKRecord.Reference(recordID: parentID, action: .deleteSelf)
            return child
        }

        records.append(parent)
        return records
    }

    /// Detect the current iCloud status for a single project
    func checkCloudStatus(_ completion: @escaping (Bool) -> Void) {
        let name = objectID.uriRepresentation().absoluteString
        let id = CKRecord.ID(recordName: name)
        let operation = CKFetchRecordsOperation(recordIDs: [id])
        operation.desiredKeys = ["recordID"]

        operation.fetchRecordsCompletionBlock = { records, _ in
            if let records = records {
                completion(records.count == 1)
            } else {
                completion(false)
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }

    // MARK: - Colors

    static let defaultColor = "AccentColor"

    static let projectColorRow = [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m" ]

    static let awardsColors = [ "aw0", "aw1", "aw2", "aw3", "aw4", "aw5", "aw6", "aw7", "aw8" ]

}
