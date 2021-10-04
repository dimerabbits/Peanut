//
//  PeanutApp.swift
//  Peanut
//
//  Created by Adam on 8/31/21.
//

import SwiftUI

@main
struct PeanutApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var persistenceController: PersistenceController
    @StateObject var unlockManager: UnlockManager
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("lastReviewRequest") var lastReviewRequest: TimeInterval?

    var askForReview: Bool {
        if let lastReviewRequest = lastReviewRequest {
            let lastReviewDistance = Date().timeIntervalSinceReferenceDate - lastReviewRequest
            // Ask only every 5 days for a review
            if  lastReviewDistance < 5*24*60*60 {
                return false
            }
        }
        return true
    }

    init() {
        let persistenceController = PersistenceController()
        let unlockManager = UnlockManager(persistenceController: persistenceController)

        _persistenceController = StateObject(wrappedValue: persistenceController)
        _unlockManager = StateObject(wrappedValue: unlockManager)

        // Workaround for "Sign-in with Apple" not working on simulator
#if targetEnvironment(simulator)
        UserDefaults.standard.set("Blitzer", forKey: "username")
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(persistenceController)
                .environmentObject(unlockManager)
                .onReceive(
                    // Automatically save when we detect that we are no longer
                    // the foreground app. Use this rather than the scene phase
                    // API so we can port to macOS, where scene phase won't detect
                    // our app losing focus as of macOS 11.1
                    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                    perform: save
                )
                // The following lines to not work as expected...
                // .onAppear(perform: persistenceController.appLaunched)
                // ... therefore I came up with the "scenePhase" monitoring below
                .onChange(of: scenePhase, perform: { newScenePhase in
                    if newScenePhase == .active && askForReview {
                        lastReviewRequest = Date().timeIntervalSinceReferenceDate
                        persistenceController.appLaunched()
                    }
                })
        }
    }

    func save(_ note: Notification) {
        persistenceController.save()
    }
}
