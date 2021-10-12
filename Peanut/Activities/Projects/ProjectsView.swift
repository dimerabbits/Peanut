//
//  ProjectsView.swift
//  Peanut
//
//  Created by Adam on 8/31/21.
//

import SwiftUI

struct ProjectsView: View {

    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"

    @StateObject private var viewModel: ViewModel
    @State private var showingSortOrder = false

    init(persistenceController: PersistenceController, showClosedProjects: Bool) {
        let viewModel = ViewModel(persistenceController: persistenceController, showClosedProjects: showClosedProjects)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.projects.count == 0 {
                    Text("There's nothing here wight now")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                }
            }
            .navigationTitle(viewModel.showClosedProjects ? "Closed Projects" : "Open Projects")
            .toolbar {
                addProjectToolbarItem
                sortOrderToolbarItem
            }
            .actionSheet(isPresented: $showingSortOrder) {
                ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                    .default(Text("Optimized")) { viewModel.sortOrder = .optimized },
                    .default(Text("Creation Date")) { viewModel.sortOrder = .creationDate },
                    .default(Text("Title")) { viewModel.sortOrder = .title }
                ])
            }

            SelectSomethingView()
        }
        .sheet(isPresented: $viewModel.showingUnlockView) {
            UnlockView()
        }
    }

    var projectsList: some View {
        List {
            ForEach(viewModel.projects) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: viewModel.sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        viewModel.delete(offsets, from: project)
                    }

                    if viewModel.showClosedProjects == false {
                        Button {
                            withAnimation {
                                viewModel.addItem(to: project)
                            }
                        } label: {
                            Label("Add New Item", systemImage: "plus")
                        }
                        .accentColor(Color(project.projectColor))
                    }
                }
            }
        }
    }

    // MARK: - Toolbar items

    var addProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.showClosedProjects == false {
                Button {
                    withAnimation {
                        viewModel.addProject()
                    }
                } label: {
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Project")
                    } else {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        }
    }

    var sortOrderToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
                    .font(.subheadline)
            }
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView(persistenceController: PersistenceController.preview,
                     showClosedProjects: false)
    }
}
