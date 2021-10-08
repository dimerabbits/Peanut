//
//  ProjectsViewModel.swift
//  Peanut
//
//  Created by Adam on 9/3/21.
//

import CoreData
import Foundation

extension ProjectsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        let persistenceController: PersistenceController
        let showClosedProjects: Bool

        private let projectsController: NSFetchedResultsController<Project>

        @Published var sortOrder = Item.SortOrder.optimized
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
                print("Failed to fetch projects")
            }
        }

        func addProject() {
            if persistenceController.addProject() == false {
                showingUnlockView.toggle()
            }
        }

        func addItem(to project: Project) {
            let item = Item(context: persistenceController.container.viewContext)
            item.priority = 2
            item.completed = false
            item.project = project
            item.creationDate = Date()
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
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }
    }
}
