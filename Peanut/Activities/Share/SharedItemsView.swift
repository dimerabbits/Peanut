//
//  SharedItemsView.swift
//  SharedItemsView
//
//  Created by Adam on 9/3/21.
//

import CloudKit
import SwiftUI

struct SharedItemsView: View {

    let project: SharedProject

    @State private var items = [SharedItem]()
    @State private var itemsLoadState = LoadState.inactive

    @State private var messages = [ChatMessage]()
    @State private var messagesLoadState = LoadState.inactive

    @AppStorage("username") var username: String?
    @State private var showSignIn = false
    @State private var newChatText = ""

    @State private var cloudError: CloudError?
    @Environment(\.colorScheme) var colorScheme

    @ViewBuilder var messagesFooter: some View {
        if username == nil {
            Button("Sign in to Comment", action: signIn)
                .frame(maxWidth: .infinity)
                .padding(.top)
        } else {
            HStack {
                TextField("Enter Message", text: $newChatText)
                    .font(.body)
                    .foregroundColor(colorScheme == .light ? .black : .white)
                    .padding(.leading)
                    .submitLabel(.done)

                Button(action: sendChatMessage) {
                    if !newChatText.isEmpty {
                        Image(systemName: "arrow.up.circle.fill")
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .font(Font.title.weight(.semibold))
            }
            .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
            .padding(.top)
        }
    }

    var body: some View {
        List {
            Section {
                switch itemsLoadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("No results")
                case .success:
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.body)

                            if item.detail.isEmpty == false {
                                Text(item.detail)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }

            Section(
                header: Text("Chat about this project…"),
                footer: messagesFooter
            ) {
                if messagesLoadState == .success {
                    ForEach(messages) { message in
                        Text("**\(Text(message.from))**: \(message.text)")
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .textCase(nil)
        }
        .listStyle(.insetGrouped)
        .navigationTitle(project.title)
        .onAppear {
            fetchSharedItems()
            fetchChatMessages()
        }
        .alert(item: $cloudError) { error in
            Alert(title: Text("There was an error"), message: Text(error.message))
        }
        .sheet(isPresented: $showSignIn, content: SignInView.init)
    }

    func fetchSharedItems() {
        guard itemsLoadState == .inactive else { return }
        itemsLoadState = .loading

        let recordID = CKRecord.ID(recordName: project.id)
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let pred = NSPredicate(format: "project == %@", reference)
        let sort = NSSortDescriptor(key: "title", ascending: true)
        let query = CKQuery(recordType: "Item", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "detail", "completed"]
        operation.resultsLimit = 50

        operation.recordFetchedBlock = { record in
            let id = record.recordID.recordName
            let title = record["title"] as? String ?? "No title"
            let detail = record["detail"] as? String ?? ""
            let completed = record["completed"] as? Bool ?? false

            let sharedItem = SharedItem(id: id, title: title, detail: detail, completed: completed)

            items.append(sharedItem)
            itemsLoadState = .success
        }

        operation.queryCompletionBlock = { _, error in
            if let error = error {
                cloudError = error.getCloudKitError()
            }

            if items.isEmpty {
                itemsLoadState = .noResults
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }

    func fetchChatMessages() {
        guard messagesLoadState == .inactive else { return }
        messagesLoadState = .loading

        let recordID = CKRecord.ID(recordName: project.id)
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let pred = NSPredicate(format: "project == %@", reference)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Message", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["from", "text"]

        operation.recordFetchedBlock = { record in
            let message = ChatMessage(from: record)
            messages.append(message)
            messagesLoadState = .success
        }

        operation.queryCompletionBlock = { _, error in
            if let error = error {
                cloudError = error.getCloudKitError()
            }

            if messages.isEmpty {
                messagesLoadState = .noResults
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }

    func signIn() {
        showSignIn = true
    }

    func sendChatMessage() {
        let text = newChatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count >= 1 else { return }
        guard let username = username else { return }

        let message = CKRecord(recordType: "Message")
        message["from"] = username
        message["text"] = text

        let projectID = CKRecord.ID(recordName: project.id)
        message["project"] = CKRecord.Reference(recordID: projectID, action: .deleteSelf)

        let backupChatText = newChatText
        newChatText = ""

        CKContainer.default().publicCloudDatabase.save(message) { record, error in
            if let error = error {
                cloudError = error.getCloudKitError()
                newChatText = backupChatText
            } else {
                if let record = record {
                    let message = ChatMessage(from: record)
                    messages.append(message)
                    messagesLoadState = .success
                }
            }
        }
    }
}

struct SharedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedItemsView(project: .example)
        SharedItemsView(project: .example)
            .preferredColorScheme(.dark)
    }
}