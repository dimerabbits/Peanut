//
//  TodayView.swift
//  Peanut
//
//  Created by Adam on 8/31/21.
//

import SwiftUI
import CoreData
import CoreSpotlight

struct TodayView: View {
    static let tag: String? = "Today"

    @StateObject private var viewModel: ViewModel
    @Environment(\.colorScheme) var colorScheme

    var projectRows: [GridItem] { [GridItem(.fixed(130))] }

    init(persistenceController: PersistenceController) {
        let viewModel = ViewModel(persistenceController: persistenceController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("**\(Date().formatted(date: .abbreviated, time: .omitted))**")

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(viewModel.projects) { project in
                                ProjectSummaryView(project: project)
                            }
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

            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Today")
            .toolbar {
                Button("Reset Data", action: viewModel.addSampleData)
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }

    // MARK: - Helper functions

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
