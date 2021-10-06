//
//  NotesHeaderView.swift
//  Peanut
//
//  Created by Adam on 9/23/21.
//

import SwiftUI

struct NotesHeaderView: View {

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            VStack(alignment: .leading) {
                Text("Notes")
            }

            Spacer()

            Button {
                hideKeyboard()
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .symbolRenderingMode(.hierarchical)
                    .font(.subheadline)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("Dismiss Keyboard")
        .accessibilityAddTraits(.isButton)
    }
}

struct NotesHeaderView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.preview

    static var previews: some View {
        EditProjectView(persistenceController: PersistenceController.preview, project: .example)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(persistenceController)
    }
}
