//
//  TodayViewModel.swift
//  Peanut
//
//  Created by Adam on 9/3/21.
//

import Foundation
import CoreData

extension TodayView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        private let projectsController: NSFetchedResultsController<Project>
        private let itemsController: NSFetchedResultsController<Item>

        var persistenceController: PersistenceController

        @Published var projects: [Project] = []
        @Published var items: [Item] = []
        @Published var selectedItem: Item?
        @Published var selectedProject: Project?
        @Published var upNext = ArraySlice<Item>()
        @Published var moreToExplore = ArraySlice<Item>()

        init(persistenceController: PersistenceController) {
            self.persistenceController = persistenceController

            /// Construct a fetch request to show all open projects
            let projectRequest: NSFetchRequest<Project> = Project.fetchRequest()
            projectRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Project.title, ascending: true)]
            projectRequest.predicate = NSPredicate(format: "closed = false")

            projectsController = NSFetchedResultsController(
                fetchRequest: projectRequest,
                managedObjectContext: persistenceController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            /// Construct a fetch request to show the 10 highest-priority, incomplete items from open projects
            let itemRequest = persistenceController.fetchRequestForTopItems(count: 10)
            itemsController = NSFetchedResultsController(
                fetchRequest: itemRequest,
                managedObjectContext: persistenceController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            /// Initialize parent object before assigning ourself as controller delegate
            super.init()

            projectsController.delegate = self
            itemsController.delegate = self

            /// Fetch initial data
            do {
                try projectsController.performFetch()
                try itemsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
                items = itemsController.fetchedObjects ?? []
                upNext = items.prefix(3)
                moreToExplore = items.dropFirst(3)
            } catch {
                print("Failed to fetch initial data.")
            }
        }

        func addSampleData() {
            persistenceController.deleteAll()
            try? persistenceController.createSampleData()
        }

        func selectItem(with identifier: String) {
            selectedItem = persistenceController.item(with: identifier)
        }

        func selectedProject(with identifier: String) {
            selectedProject = persistenceController.project(with: identifier)
        }

        // MARK: - NSFetchedResultsControllerDelegate

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            items = itemsController.fetchedObjects ?? []

            upNext = items.prefix(3)
            moreToExplore = items.dropFirst(3)

            projects = projectsController.fetchedObjects ?? []
        }
    }
}
