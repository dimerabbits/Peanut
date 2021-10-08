//
//  EditProjectView.swift
//  Peanut
//
//  Created by Adam on 8/31/21.
//

import SwiftUI
import CloudKit
import CoreHaptics

struct EditProjectView: View {

    @ObservedObject var project: Project
    @EnvironmentObject var persistenceController: PersistenceController
    @AppStorage("username") var username: String?

    let colorRow = [ GridItem(.adaptive(minimum: 44)) ]

    @State private var showingNotificationError = false
    @State private var showingSignIn = false
    @State private var showingDeleteConfirm = false
    @State private var cloudError: CloudError?

    @State private var cloudStatus = CloudStatus.checking
    enum CloudStatus { case checking, exists, absent }

    @FocusState private var focusedField: Field?
    enum Field { case projectName, projectDescription }

    @State private var engine = try? CHHapticEngine()

    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var note: String
    @State private var remindMe: Bool
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
                        isPresented: $showingNotificationError,
                        titleVisibility: .visible
                    ) {
                        Button("Check Settings", role: .none) { showAppSettings() }
                    }

                if remindMe {
                    DatePicker("Reminder time",
                               selection: $reminderTime.onChange(update),
                               displayedComponents: [.hourAndMinute, .date])
                        .datePickerStyle(.graphical)
                }
            }

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
                Button("Delete", role: .destructive) { showingDeleteConfirm.toggle() }
                .confirmationDialog(
                    "Permanently erase this project and all of it's items?",
                    isPresented: $showingDeleteConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) { delete() }
                }
            }

            Section(header: NotesHeaderView()) {
                TextEditor(text: $note.onChange(update))
                    .frame(minHeight: 200)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
            }
            .textCase(nil)
        }
        .navigationTitle("Edit Project")
        .toolbar {
            switch cloudStatus {
            case .checking:
                ProgressView()
            case .exists:
                Button(action: removeFromCloud) { Label("Remove from iCloud", systemImage: "icloud.slash") }
            case .absent:
                Button(action: uploadToCloud) { Label("Upload to iCloud", systemImage: "icloud.and.arrow.up") }
            }
        }
        .onAppear(perform: updateCloudStatus)
        .onDisappear(perform: save)
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
                .cornerRadius(10)

            if item == color {
                Image(systemName: "scribble.variable")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = item
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == color
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
                    case .failure(let error):
                        self.cloudError = error.getCloudKitError()
                    case .success:
                        break
                    }
                }

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

        operation.modifyRecordsResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self.cloudError = error.getCloudKitError()
                case .success:
                    break
                }
            }

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

    func save() { persistenceController.save() }

    func delete() { persistenceController.delete(project) }

    func update() {
        project.objectWillChange.send()

        project.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        project.detail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        project.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        project.color = color

        if remindMe {
            project.reminderTime = reminderTime

            persistenceController.addReminders(for: project) { success in
                if success == false {
                    self.project.reminderTime = nil
                    self.remindMe = false
                    self.showingNotificationError = true
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
            /// UINotificationFeedbackGenerator().notificationOccurred(.success)
            do {
                try engine?.start()
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
                /// use that curve to control the haptic strength
                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )
                /// transient, strong and dull, and starting immediately
                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )
                /// a continuous haptic event starting immediately and lasting one second
                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [sharpness, intensity],
                    relativeTime: 0.125,
                    duration: 1
                )
                /// events into single sequence & haptic fades with strength
                let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter])
                /// Make player
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                /// if haptics didn't work, its ok!
                debugPrint("Error when working with haptics: \(error.localizedDescription)")
            }
        }
    }

    func showAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}
