//
//  TodayView.swift
//  TodayView
//
//  Created by Adam on 8/31/21.
//

import CoreData
import CoreSpotlight
import SwiftUI

struct TodayView: View {
    static let tag: String? = "Today"

    @StateObject private var viewModel: ViewModel
    @Environment(\.colorScheme) var colorScheme

    init(persistenceController: PersistenceController) {
        let viewModel = ViewModel(persistenceController: persistenceController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var projectRows: [GridItem] { [GridItem(.fixed(130))] }

    var body: some View {
        NavigationView {
            ScrollView {
                if let item = viewModel.selectedItem {
                    NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $viewModel.selectedItem,
                        label: EmptyView.init
                    )
                    .id(item)
                }

                if let project = viewModel.selectedProject {
                    NavigationLink(
                        destination: EditProjectView(project: project),
                        tag: project,
                        selection: $viewModel.selectedProject,
                        label: EmptyView.init
                    )
                    .id(project)
                }

                VStack(alignment: .leading) {
                    Text("**\(Date().formatted(date: .abbreviated, time: .omitted))**")

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(viewModel.projects, content: ProjectSummaryView.init)
                        }
                        .padding(10)
                        .fixedSize(horizontal: true, vertical: true)
                    }

                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: $viewModel.upNext)
                        ItemListView(title: "More to explore", items: $viewModel.moreToExplore)
                    }
                }
                .padding(.horizontal)
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Today")
            .toolbar {
                if viewModel.items.isEmpty {
                    Button("Add Data") {
                        viewModel.addSampleData()
                    }
                } else {
                    Button("Delete all", action: viewModel.persistenceController.deleteAll)
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }

    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            viewModel.selectItem(with: uniqueIdentifier)
        }
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(persistenceController: .preview)
        TodayView(persistenceController: .preview)
            .preferredColorScheme(.dark)
    }
}
