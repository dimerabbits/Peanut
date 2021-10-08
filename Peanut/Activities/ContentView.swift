//
//  ContentView.swift
//  Peanut
//
//  Created by Adam on 8/31/21.
//

import SwiftUI
import CoreSpotlight
import CloudKit

struct ContentView: View {
    private let newProjectActivity = "com.adam.Peanut.newProject"

    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @SceneStorage("selectedView") var selectedView: String?
    @EnvironmentObject var persistenceController: PersistenceController

    var body: some View {
        TabView(selection: $selectedView) {
            TodayView(persistenceController: persistenceController)
                .tag(TodayView.tag)
                .tabItem {
                    Image(systemName: "doc.text.image")
                    Text("Today")
                }

            ProjectsView(persistenceController: persistenceController, showClosedProjects: false)
                .tag(ProjectsView.openTag)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }

            ProjectsView(persistenceController: persistenceController, showClosedProjects: true)
                .tag(ProjectsView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
                }

            AwardsView()
                .tag(AwardsView.tag)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Awards")
                }

            SharedProjectsView()
                .tag(SharedProjectsView.tag)
                .tabItem {
                    Image(systemName: "person.2.wave.2")
                    Text("Share")
                }
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveToToday)
        .onContinueUserActivity(newProjectActivity, perform: createProject)
        .userActivity(newProjectActivity) { activity in
            activity.isEligibleForPrediction = true
            activity.title = "New Project"
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
