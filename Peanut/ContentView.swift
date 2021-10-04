//
//  ContentView.swift
//  Peanut
//
//  Created by Adam on 8/31/21.
//

import SwiftUI
import CoreSpotlight

struct ContentView: View {
    @SceneStorage("selectedView") var selectedView: String?
    @EnvironmentObject var persistenceController: PersistenceController
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true

    private let newProjectActivity = "com.adam.Peanut.newProject"

    var body: some View {
        TabView(selection: $selectedView) {
            TodayView(persistenceController: persistenceController)
                .tag(TodayView.tag)
                .tabItem({ Label("Today", systemImage: "doc.text.image") })

            ProjectsView(persistenceController: persistenceController, showClosedProjects: false)
                .tag(ProjectsView.openTag)
                .tabItem({ Label("Open", systemImage: "list.bullet") })

            ProjectsView(persistenceController: persistenceController, showClosedProjects: true)
                .tag(ProjectsView.closedTag)
                .tabItem({ Label("Closed", systemImage: "checkmark") })

            AwardsView()
                .tag(AwardsView.tag)
                .tabItem({ Label("Awards", systemImage: "rosette") })

            SharedProjectsView()
                .tag(SharedProjectsView.tag)
                .tabItem({ Label("Share", systemImage: "person.2.wave.2") })
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveToToday)
        .onContinueUserActivity(newProjectActivity, perform: createProject)
        .userActivity(newProjectActivity) { activity in
            activity.title = "New Project"
            activity.isEligibleForPrediction = true
        }
        .onOpenURL(perform: openURL)
        .sheet(isPresented: $isFirstLaunch) {
            WelcomeView()
        }
    }

    func moveToToday(_ input: Any) {
        selectedView = TodayView.tag
    }

    func openURL(_ url: URL) {
        selectedView = ProjectsView.openTag
        persistenceController.addProject()
    }

    func createProject(_ userActivity: NSUserActivity) {
        selectedView = ProjectsView.openTag
        persistenceController.addProject()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.preview

    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(persistenceController)
    }
}
