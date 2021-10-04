//
//  AwardsView.swift
//  AwardsView
//
//  Created by Adam on 8/31/21.
//

import SwiftUI

struct AwardsView: View {
    static let tag: String? = "Awards"

    @EnvironmentObject var persistenceController: PersistenceController
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false

    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 100))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails.toggle()
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(color(for: award))
                        }
                        .accessibility(label: label(for: award))
                        .accessibility(hint: Text(award.description))
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $showingAwardDetails) {
            getAwardAlert()
        }
    }

    func color(for award: Award) -> Color {
        persistenceController.hasEarned(award: award) ? Color(award.color) : Color.secondary.opacity(0.5)
    }

    func label(for award: Award) -> Text {
        Text(persistenceController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked")
    }

    func getAwardAlert() -> Alert {
        if persistenceController.hasEarned(award: selectedAward) {
            return Alert(
                title: Text("Unlocked: \(selectedAward.name)"),
                message: Text(selectedAward.description),
                dismissButton: .default(Text("OK"))
            )
        } else {
            return Alert(
                title: Text("Locked"),
                message: Text(selectedAward.description),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
