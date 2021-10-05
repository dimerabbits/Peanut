//
//  ProjectsViewModel.swift
//  ProjectsViewModel
//
//  Created by Adam on 9/3/21.
//

import Foundation
import CoreData

extension ProjectsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        @Published var showingUnlockView = false

        let persistenceController: PersistenceController
        var sortOrder = Item.SortOrder.optimized
        let showClosedProjects: Bool

        private let projectsController: NSFetchedResultsController<Project>
        @Published var projects = [Project]()

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
                cacheName: nil)

            super.init()
            projectsController.delegate = self

            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                fatalError("Failed to fetch projects")
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

        func addProject() {
            if persistenceController.addProject() == false {
                showingUnlockView.toggle()
            }
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
