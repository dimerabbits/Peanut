//
//  EditProjectView.swift
//  EditProjectView
//
//  Created by Adam on 8/31/21.
//

import CloudKit
import CoreHaptics
import SwiftUI

struct EditProjectView: View {

    @ObservedObject var project: Project
    @EnvironmentObject var persistenceController: PersistenceController

    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var note: String

    @State private var remindMe = false
    @State private var reminderTime: Date

    init(project: Project) {
        self.project = project
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
        _note = State(wrappedValue: project.projectNote)
        if let projectReminderTime = project.reminderTime {
            _reminderTime = State(wrappedValue: projectReminderTime)
            _remindMe = State(wrappedValue: true)
        } else {
            _reminderTime = State(wrappedValue: Date())
            _remindMe = State(wrappedValue: false)
        }
    }

    @State private var showingDeleteConfirm = false
    @State private var showingNotificationsError = false

    @State private var engine = try? CHHapticEngine()

    @AppStorage("username") var username: String?
    @State private var showingSignIn = false

    @State private var cloudError: CloudError?
    @State private var cloudStatus = CloudStatus.checking

    enum CloudStatus {
        case checking, exists, absent
    }

    @FocusState private var focusedField: Field?

    enum Field {
        case projectName, projectDescription
    }

    let colorRow = [ GridItem(.adaptive(minimum: 44)) ]

    var body: some View {
        Form {
            Section {
                CustomTextField("Project name", text: $title.onChange(update))
                    .focused($focusedField, equals: .projectName)
                    .submitLabel(.next)

                CustomTextField("Project Description", text: $detail.onChange(update))
                    .focused($focusedField, equals: .projectDescription)
                    .submitLabel(.done)

                Toggle("Show reminders", isOn: $remindMe.animation().onChange(update))
                    .confirmationDialog(
                        "There was a problem. Please check you have notifications enabled.",
                        isPresented: $showingNotificationsError,
                        titleVisibility: .visible
                    ) {
                        Button("Check Settings", role: .none) {
                            showAppSettings()
                        }
                    }

                if remindMe {
                    DatePicker("Reminder time",
                               selection: $reminderTime.onChange(update),
                               displayedComponents: [.hourAndMinute, .date])
                        .datePickerStyle(.graphical)
                }
            }

            Section(header: NotesHeaderView()) {
                TextEditor(text: $note.onChange(update))
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
                Button(project.closed ? "Reopen" : "Close", action: toggleClosed)
                Button("Delete") {
                    showingDeleteConfirm.toggle()
                }
                .tint(.red)
                .confirmationDialog(
                    "Permanently erase this project and all of it's items?",
                    isPresented: $showingDeleteConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        delete()
                    }
                }
            }
        }
        .onAppear(perform: updateCloudStatus)
        .onDisappear(perform: persistenceController.save)
        .navigationTitle("Edit Project")
        .toolbar {
            switch cloudStatus {
            case .checking:
                ProgressView()
            case .exists:
                Button(action: removeFromCloud) {
                    Label("Remove from iCloud", systemImage: "icloud.slash")
                        .font(.subheadline)
                }
            case .absent:
                Button(action: uploadToCloud) {
                    Label("Upload to iCloud", systemImage: "icloud.and.arrow.up")
                        .font(.subheadline)
                }
            }
        }
        .alert(item: $cloudError) { error in
            Alert(title: Text("There was an error"),
                  message: Text(error.message))
        }
        .onSubmit {
            switch focusedField {
            case .projectName:
                focusedField = .projectDescription
            default:
                print("Project Edited")
            }
        }
        .sheet(isPresented: $showingSignIn, content: SignInView.init)
    }

    func update() {
        project.objectWillChange.send()

        project.title = title.trimmingCharacters(in: .whitespaces)
        project.detail = detail.trimmingCharacters(in: .whitespaces)
        project.note = note.trimmingCharacters(in: .whitespaces)
        project.color = color

        if remindMe {
            project.reminderTime = reminderTime
            persistenceController.addReminders(for: project) { success in
                if success == false {
                    self.project.reminderTime = nil
                    self.remindMe = false
                    showingNotificationsError = true
                }
            }
        } else {
            project.reminderTime = nil
            persistenceController.removeReminders(for: project)
        }
    }

    func toggleClosed() {
        project.closed.toggle()
        if project.closed {
            // UINotificationFeedbackGenerator().notificationOccurred(.success)
            do {
                try engine?.start()
                let sharpness = CHHapticEventParameter( parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
                // use that curve to control the haptic strength
                let parameter = CHHapticParameterCurve(parameterID: .hapticIntensityControl,
                                                       controlPoints: [start, end],
                                                       relativeTime: 0)
                // transient, strong and dull, and starting immediately
                let event1 = CHHapticEvent(eventType: .hapticTransient,
                                           parameters: [intensity, sharpness],
                                           relativeTime: 0)
                // a continuous haptic event starting immediately and lasting one second
                let event2 = CHHapticEvent(eventType: .hapticContinuous,
                                           parameters: [sharpness, intensity],
                                           relativeTime: 0.12,
                                           duration: 1)
                // events into single sequence & haptic fades with strength
                let pattern = try CHHapticPattern(events: [event1, event2],
                                                  parameterCurves: [parameter])
                // Make player
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                // playing haptics didn't work, but its ok!
            }
        }
        update()
    }

    func delete() {
        persistenceController.delete(project)
    }

    func colorButton(for item: String) -> some View {
        ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(10)

            if item == color {
                Image(systemName: "scribble.variable")
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
        .onTapGesture {
            color = item
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibility(addTraits: color == item ? [.isButton, .isSelected] : [.isButton])
        .accessibilityLabel(LocalizedStringKey(item))
    }

    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }

    func uploadToCloud() {
        if let username = username {
            let records = project.prepareCloudRecords(owner: username)
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.savePolicy = .allKeys
            operation.modifyRecordsCompletionBlock = { _, _, error in
                if let error = error { cloudError = error.getCloudKitError() }
                updateCloudStatus()
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
        operation.modifyRecordsCompletionBlock = { _, _, error in
            if let error = error { cloudError = error.getCloudKitError() }
            updateCloudStatus()
        }
        cloudStatus = .checking
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    func updateCloudStatus() {
        project.checkCloudStatus { exists in
            if exists {
                cloudStatus = .exists
            } else {
                cloudStatus = .absent
            }
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.preview
    static var previews: some View {
        EditProjectView(project: .example)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(persistenceController)
    }
}
