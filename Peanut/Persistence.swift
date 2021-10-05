//
//  Persistence.swift
//  Peanut
//
//  Created by Adam on 8/31/21.
//

import SwiftUI
import CoreData
import CoreSpotlight
import WidgetKit

/// An enviornment singleton responsible for managing our Core Data stack,
/// including handling saving, counting fetch request, tracking awards, and dealing with sample data
class PersistenceController: ObservableObject {

    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer

    /// The UserDefaults suite where we're saving user data.
    let defaults: UserDefaults

    /// Loads and saves whether our premium unlock has been purchased
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }

        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }

    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs).
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    /// - Parameter defaults: The UserDefaults suite where user data should be stored.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        container = NSPersistentCloudKitContainer(name: "Peanut", managedObjectModel: Self.model)

        /// For testing and previewing purposes, we create a temporary,
        /// in-memory database by writing to /dev/null so our data is
        /// destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let groupID = "group.com.adam.Peanut"

            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appendingPathComponent("Peanut.sqlite")
            }
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            self.container.viewContext.automaticallyMergesChangesFromParent = true

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
            #endif
        }
    }

    static var preview: PersistenceController = {
        let persistenceController = PersistenceController(inMemory: true)
        let viewContext = persistenceController.container.viewContext

        do {
            try persistenceController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }

        return persistenceController
    }()

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Peanut", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }
        return managedObjectModel
    }()

    /// Creates example projects and items to make manunal testing easier.
    ///  - Throws: an NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = container.viewContext

        for outer in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(outer)"
            project.items = []
            project.creationDate = Date()
            project.closed = Bool.random()

            for inner in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(inner)"
                item.creationDate = Date()
                item.completed = false
                item.project = project
                item.priority = Int16.random(in: 1...3)

                item.completed = Bool.random()
            }
        }

        try viewContext.save()
    }

    /// Saves our Core Data context if there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all our attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func delete(_ object: NSManagedObject) {
        /// Remove data from Spotlight database
        let id = object.objectID.uriRepresentation().absoluteString
        if object is Item {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
        } else {
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
        }
        /// Remove object from Core Data
        container.viewContext.delete(object)
    }

    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        delete(fetchRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        delete(fetchRequest2)
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? [] ]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    func update(_ item: Item) {
        /// Use Core Data URI to identify item in Spotlight database
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.objectID.uriRepresentation().absoluteString

        /// Add title and detail as searchable attribute
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.itemTitle
        attributeSet.contentDescription = item.itemDetail

        /// Add item to Spotlight index
        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: projectID,
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([searchableItem])

        save()
    }

    func item(with uniqueIdentifier: String) -> Item? {
        guard let url = URL(string: uniqueIdentifier) else { return nil }

        guard let id = container.persistentStoreCoordinator.managedObjectID(
            forURIRepresentation: url) else { return nil }

        return try? container.viewContext.existingObject(with: id) as? Item
    }

    func project(with uniqueIdentifier: String) -> Project? {
        guard let url = URL(string: uniqueIdentifier) else { return nil }

        guard let id = container.persistentStoreCoordinator.managedObjectID(
            forURIRepresentation: url) else { return nil }

        return try? container.viewContext.existingObject(with: id) as? Project
    }

    @discardableResult func addProject() -> Bool {
        let canCreate = fullVersionUnlocked || count(for: Project.fetchRequest()) < 3

        if canCreate {
            let project = Project(context: container.viewContext)
            project.closed = false
            project.creationDate = Date()
            save()
            return true
        } else {
            return false
        }
    }

    func fetchRequestForTopItems(count: Int) -> NSFetchRequest<Item> {
        let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()

        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "project.closed = false")
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
        itemRequest.predicate = compoundPredicate

        itemRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        ]

        itemRequest.fetchLimit = count
        return itemRequest
    }

    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
}
