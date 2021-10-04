//
//  ProjectsViewModel.swift
//  ProjectsViewModel
//
//  Created by Adam on 9/3/21.
//

import CoreData
import Foundation

extension ProjectsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        let persistenceController: PersistenceController
        let showClosedProjects: Bool

        @Published var sortOrder = Item.SortOrder.optimized

        private let projectsController: NSFetchedResultsController<Project>
        @Published var projects = [Project]()

        @Published var showingUnlockView = false

        init(persistenceController: PersistenceController, showClosedProjects: Bool) {
            self.persistenceController = persistenceController
            self.showClosedProjects = showClosedProjects

            let request: NSFetchRequest<Project> = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d", showClosedProjects)

            projectsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: persistenceController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()
            projectsController.delegate = self

            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch our projects!")
            }
        }

        func addProject() {
            let canCreate = persistenceController.fullVersionUnlocked ||
            persistenceController.count(for: Project.fetchRequest()) < 3

            if canCreate {
                persistenceController.addProject()
            } else {
                showingUnlockView.toggle()
            }
        }

        func addItem(to project: Project) {
            let item = Item(context: persistenceController.container.viewContext)
            item.project = project
            item.creationDate = Date()
            item.priority = 2
            item.completed = false
            persistenceController.save()
        }

        func delete(_ offsets: IndexSet, from project: Project) {
            let allItems = project.projectItems(using: sortOrder)
            for offset in offsets {
                let item = allItems[offset]
                persistenceController.delete(item)
            }
            persistenceController.save()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            projects = projectsController.fetchedObjects ?? []
        }
    }
}
