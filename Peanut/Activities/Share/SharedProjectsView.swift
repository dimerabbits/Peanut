//
//  SharedProjectView.swift
//  Peanut
//
//  Created by Adam on 9/3/21.
//

import SwiftUI
import CloudKit

struct SharedProjectsView: View {
    static let tag: String? = "Share"

    @State private var projects = [SharedProject]()
    @State private var loadState = LoadState.inactive
    @State private var cloudError: CloudError?

    var body: some View {
        NavigationView {
            Group {
                switch loadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("No results")
                case .success:
                    List(projects) { project in
                        NavigationLink(destination: SharedItemsView(project: project)) {
                            VStack(alignment: .leading) {
                                Text(project.title)
                                    .font(.headline)
                                Text(project.owner)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .alert(item: $cloudError) { error in
                Alert(title: Text("There was an error"), message: Text(error.message))
            }
            .navigationTitle("Shared Projects")
        }
        .onAppear(perform: fetchSharedProjects)
    }

    // MARK: - CloudKit

    func fetchSharedProjects() {
        guard loadState == .inactive else { return }
        loadState = .loading

        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Project", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "detail", "owner", "closed"]
        operation.resultsLimit = 50
        operation.recordMatchedBlock = { record, result in
            switch result {
            case .failure(let error):
                cloudError = error.getCloudKitError()
            case .success(let record):
                let id = record.recordID.recordName
                let title = record["title"] as? String ?? "No title"
                let detail = record["detail"] as? String ?? ""
                let owner = record["owner"] as? String ?? "No owner"
                let closed = record["closed"] as? Bool ?? false

                let sharedProject = SharedProject(
                    id: id,
                    title: title,
                    detail: detail,
                    owner: owner,
                    closed: closed
                )
                projects.append(sharedProject)
                loadState = .success

            }
        }

        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self.cloudError = error.getCloudKitError()
                case .success:
                    break
                }
            }

            if projects.isEmpty {
                loadState = .noResults
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct SharedProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedProjectsView()
    }
}
