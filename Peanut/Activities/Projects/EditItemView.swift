//
//  EditItemView.swift
//  EditItemView
//
//  Created by Adam on 8/31/21.
//

import SwiftUI

struct EditItemView: View {
    let item: Item

    @EnvironmentObject var persistenceController: PersistenceController

    @State private var title: String
    @State private var detail: String
    @State private var note: String
    @State private var priority: Int
    @State private var completed: Bool

    init(item: Item) {
        self.item = item
        _title = State(wrappedValue: item.itemTitle)
        _detail = State(wrappedValue: item.itemDetail)
        _note = State(wrappedValue: item.itemNote)
        _priority = State(wrappedValue: Int(item.priority))
        _completed = State(wrappedValue: item.completed)
    }

    @FocusState private var focusedField: Field?

    enum Field {
        case itemName, itemDescription
    }

    var body: some View {
        Form {
            Section {
                CustomTextField("Item name", text: $title.onChange(update))
                    .focused($focusedField, equals: .itemName)
                    .submitLabel(.next)

                CustomTextField("Description", text: $detail.onChange(update))
                    .focused($focusedField, equals: .itemDescription)
                    .submitLabel(.done)
            }

            Section {
                Picker("Priority", selection: $priority.onChange(update)) {
                    Text("Low").tag(1)
                    Text("Medium").tag(2)
                    Text("High").tag(3)
                }
                .pickerStyle(.segmented)
            }

            Section {
                Toggle("Mark Completed", isOn: $completed.onChange(update))
                    .tint(.accentColor)
            }

            Section(header: NotesHeaderView()) {
                TextEditor(text: $note.onChange(update))
                    .foregroundColor(Color.gray)
                    .font(.custom("HelveticaNeue", size: 16))
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
            }
            .textCase(nil)
        }
        .navigationTitle("Edit Item")
        .onDisappear(perform: save)
        .onSubmit {
            switch focusedField {
            case .itemName:
                focusedField = .itemDescription
            default:
                print("Item Created")
            }
        }
    }

    func update() {
        item.project?.objectWillChange.send()

        item.title = title.trimmingCharacters(in: .whitespaces)
        item.detail = detail.trimmingCharacters(in: .whitespaces)
        item.note = note.trimmingCharacters(in: .whitespaces)
        item.priority = Int16(priority)
        item.completed = completed
    }

    func save() {
        persistenceController.update(item)
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.preview

    static var previews: some View {
        EditItemView(item: Item.example)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(persistenceController)
    }
}
