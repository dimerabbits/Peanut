//
//  EditProjectViewModel.swift
//  Peanut
//
//  Created by Adam on 10/6/21.
//

import SwiftUI
import CloudKit
import Combine
import CoreHaptics

extension EditProjectView {
    class ViewModel: ObservableObject {
        let persistenceController: PersistenceController
        let project: Project

        @Published var engine = try? CHHapticEngine()

        @Published var title: String
        @Published var detail: String
        @Published var color: String
        @Published var note: String
        @Published var remindMe = false
        @Published var reminderTime: Date

        @Published var showingNotificationsError = false
        @Published var showingDeleteConfirm = false

        init(persistenceController: PersistenceController, project: Project) {
            self.persistenceController = persistenceController
            self.project = project

            _title = Published(wrappedValue: project.projectTitle)
            _detail = Published(wrappedValue: project.projectDetail)
            _color = Published(wrappedValue: project.projectColor)
            _note = Published(wrappedValue: project.projectNote)
            if let projectReminderTime = project.reminderTime {
                _reminderTime = Published(wrappedValue: projectReminderTime)
                _remindMe = Published(wrappedValue: true)
            } else {
                _reminderTime = Published(wrappedValue: Date())
                _remindMe = Published(wrappedValue: false)
            }
        }

        func save() {
            persistenceController.save()
        }

        func delete() {
            persistenceController.delete(project)
        }

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
                        self.showingNotificationsError = true
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

    enum CloudStatus {
        case checking, exists, absent
    }
}
