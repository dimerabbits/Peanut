//
//  AwardsView.swift
//  AwardsView
//
//  Created by Adam on 8/31/21.
//

import SwiftUI

struct AwardsView: View {
    static let tag: String? = "Awards"

    @StateObject var viewModel: ViewModel

    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }

    init(persistenceController: PersistenceController) {
        let viewModel = ViewModel(persistenceController: persistenceController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(color(for: award))
                        }
                        .accessibilityLabel(label(for: award))
                        .accessibilityHint(Text(award.description))
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $showingAwardDetails, content: getAwardAlert)
    }

    // MARK: - Helper functions

    func color(for award: Award) -> Color {
        viewModel.color(for: award).map { Color($0) } ?? Color.secondary.opacity(0.5)
    }

    func label(for award: Award) -> Text {
        Text(viewModel.label(for: award))
    }

    func getAwardAlert() -> Alert {
        if viewModel.hasEarned(award: selectedAward) {
            return Alert(
                title: Text("Unlocked: \(selectedAward.name)"),
                message: Text("\(Text(selectedAward.description))"),
                dismissButton: .default(Text("OK"))
            )
        } else {
            return Alert(
                title: Text("Locked"),
                message: Text("\(Text(selectedAward.description))"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView(persistenceController: .preview)
    }
}
