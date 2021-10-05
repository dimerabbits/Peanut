//
//  Persistence-Awards.swift
//  Peanut
//
//  Created by Adam on 9/2/21.
//

import CoreData

extension PersistenceController {
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "items":
            /// returns try if they added a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "complete":
            /// returns true if they completed a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        default:
            /// an unknown award criterion; this should never be allowed
            break
        }
        return false
    }
}
