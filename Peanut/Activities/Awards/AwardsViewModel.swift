//
//  AwardsViewModel.swift
//  Peanut
//
//  Created by Adam on 10/5/21.
//

import Foundation

extension AwardsView {
    class ViewModel: ObservableObject {
        let persistenceController: PersistenceController

        init(persistenceController: PersistenceController) {
            self.persistenceController = persistenceController
        }

        func color(for award: Award) -> String? {
            persistenceController.hasEarned(award: award) ? award.color : nil
        }

        func label(for award: Award) -> String {
            persistenceController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked"
        }

        func hasEarned(award: Award) -> Bool {
            persistenceController.hasEarned(award: award)
        }
    }
}
