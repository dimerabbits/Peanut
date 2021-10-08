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

    init() {
        let persistenceController = PersistenceController()
        let unlockManager = UnlockManager(persistenceController: persistenceController)

        _persistenceController = StateObject(wrappedValue: persistenceController)
        _unlockManager = StateObject(wrappedValue: unlockManager)
    }

    var body: some Scene {
        WindowGroup {
        ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(persistenceController)
                .environmentObject(unlockManager)
                // Automatically save when we detect that we are no longer
                // the foreground app. Use this rather than the scene phase
                // API so we can port to macOS, where scene phase won't detect
                // App loses focus as of macOS 11.1
                .onReceive(
                    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                    perform: save
                )
                .onAppear(perform: persistenceController.appLaunched)
        }
    }

    func save(_ note: Notification) {
        persistenceController.save()
    }
}
