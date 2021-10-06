//
//  EditProjectView.swift
//  EditProjectView
//
//  Created by Adam on 8/31/21.
//

import SwiftUI
import CloudKit
import Combine
import CoreHaptics

struct EditProjectView: View {

    @StateObject var viewModel: ViewModel
    @ObservedObject var project: Project

    @AppStorage("username") var username: String?

    @State private var cloudStatus = CloudStatus.checking
    @State private var showingSignIn = false
    @State private var isBusy = false
    @State private var cloudError: CloudError?

    @FocusState private var focusedField: Field?

    enum Field {
        case projectName, projectDescription
    }

    let colorRow = [ GridItem(.adaptive(minimum: 44)) ]

    init(persistenceController: PersistenceController, project: Project) {
        self.project = project
        let viewModel = ViewModel(persistenceController: persistenceController, project: project)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                CustomTextField("Project name", text: $viewModel.title.onChange(viewModel.update))
                    .focused($focusedField, equals: .projectName)
                    .submitLabel(.next)

                CustomTextField("Project Description", text: $viewModel.detail.onChange(viewModel.update))
                    .focused($focusedField, equals: .projectDescription)
                    .submitLabel(.done)

                Toggle("Show reminders", isOn: $viewModel.remindMe.animation().onChange(viewModel.update))
                    .confirmationDialog(
                        "There was a problem. Please check you have notifications enabled.",
                        isPresented: $viewModel.showingNotificationsError,
                        titleVisibility: .visible
                    ) {
                        Button("Check Settings", role: .none) {
                            viewModel.showAppSettings()
                        }
                    }

                if viewModel.remindMe {
                    DatePicker(
                        "Reminder time",
                        selection: $viewModel.reminderTime.onChange(viewModel.update),
                        displayedComponents: [.hourAndMinute, .date])
                        .datePickerStyle(.graphical)
                }
            }

            Section(header: NotesHeaderView()) {
                TextEditor(text: $viewModel.note.onChange(viewModel.update))
                    .foregroundColor(Color.gray)
                    .font(.custom("HelveticaNeue", size: 16))
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
            }
            .textCase(nil)

            Section(header: Text("Project Color")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: colorRow) {
                        ForEach(Project.projectColorRow, id: \.self, content: colorButton)
                    }
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
            .textCase(nil)

            Section {
                Button(viewModel.project.closed ? "Reopen" : "Close", action: viewModel.toggleClosed)
                Button("Delete") {
                    viewModel.showingDeleteConfirm.toggle()
                }
                .tint(.red)
                .confirmationDialog(
                    "Permanently erase this project and all of it's items?",
                    isPresented: $viewModel.showingDeleteConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        viewModel.delete()
                    }
                }
            }
        }
        .navigationTitle("Edit Project")
        .toolbar {
            switch cloudStatus {
            case .checking:
                ProgressView()
            case .exists:
            Button(action: removeFromCloud) {
                        Label("Remove from iCloud", systemImage: "icloud.slash")
                    }
            case .absent:
                Button(action: uploadToCloud) {
                    Label("Upload to iCloud", systemImage: "icloud.and.arrow.up")
                }
            }
        }
        .onAppear(perform: updateCloudStatus)
        .onDisappear(perform: viewModel.save)
        .onSubmit {
            switch focusedField {
            case .projectName:
                focusedField = .projectDescription
            default:
                print("Project Edited")
            }
        }
        .sheet(isPresented: $showingSignIn, content: SignInView.init)
        .alert(item: $cloudError) { error in
            Alert(
                title: Text("There was an error"),
                message: Text(error.message)
            )
        }
    }

    // MARK: - Support View

    func colorButton(for item: String) -> some View {
        ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)

            if item == viewModel.color {
                Image(systemName: "scribble.variable")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            viewModel.color = item
            viewModel.update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == viewModel.color
            ? [.isButton, .isSelected]
            : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(item))
    }

    // MARK: - iCloud

    func uploadToCloud() {
        if let username = username {
            let records = project.prepareCloudRecords(owner: username)
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.savePolicy = .allKeys

            operation.modifyRecordsResultBlock = { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success: break
                    case .failure(let error): self.cloudError = error.getCloudKitError()
                    }
                }
                self.isBusy = false

                self.updateCloudStatus()
            }

            cloudStatus = .checking
            CKContainer.default().publicCloudDatabase.add(operation)
        } else {
            showingSignIn = true
        }
    }

    func removeFromCloud() {
        let name = project.objectID.uriRepresentation().absoluteString
        let id = CKRecord.ID(recordName: name)

        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [id])

        operation.modifyRecordsResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success: break
                case .failure(let error): self.cloudError = error.getCloudKitError()
                }
            }
            self.isBusy = false

            self.updateCloudStatus()
        }

        cloudStatus = .checking
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    func updateCloudStatus() {
        project.checkCloudStatus { [self] exists in
            if exists {
                cloudStatus = .exists
            } else {
                cloudStatus = .absent
            }
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(persistenceController: PersistenceController.preview, project: Project.example)
    }
}
