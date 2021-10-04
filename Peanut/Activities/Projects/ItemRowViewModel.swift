//
//  ItemRowViewModel.swift
//  ItemRowViewModel
//
//  Created by Adam on 9/5/21.
//

import Foundation

extension ItemRowView {
    class ViewModel: ObservableObject {
        let project: Project
        let item: Item

        var title: String {
            item.itemTitle
        }

        var icon: String {
            if item.completed {
                return "checkmark.circle.fill"
            } else if item.priority == 3 {
                return "arrowtriangle.up.circle"
            } else if item.priority == 1 {
                return "arrowtriangle.down.circle"
            } else {
                return "checkmark.circle.fill"
            }
        }

        var color: String? {
            if item.completed {
                return project.projectColor
            } else if item.priority == 3 {
                return project.projectColor
            } else if item.priority == 1 {
                return project.projectColor
            } else {
                return nil
            }
        }

        var label: String {
            if item.completed {
                return "\(item.itemTitle), completed."
            } else if item.priority == 3 {
                return "\(item.itemTitle), high priority."
            } else if item.priority == 1 {
                return "\(item.itemTitle), low priority."
            } else {
                return item.itemTitle
            }
        }

        init(project: Project, item: Item) {
            self.project = project
            self.item = item
        }
    }
}
