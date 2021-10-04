//
//  ItemRowView.swift
//  ItemRowView
//
//  Created by Adam on 8/31/21.
//

import SwiftUI

struct ItemRowView: View {
    @StateObject var viewModel: ViewModel
    @ObservedObject var item: Item

    init(project: Project, item: Item) {
        let viewModel = ViewModel(project: project, item: item)
        _viewModel = StateObject(wrappedValue: viewModel)
        self.item = item
    }

    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(viewModel.title)
            } icon: {
                Image(systemName: viewModel.icon)
                    .symbolRenderingMode(.hierarchical)
                    .font(.footnote)
                    .foregroundColor(viewModel.color.map { Color($0) } ?? .clear)
                    .opacity(0.8)
            }
        }
        .accessibility(label: Text(viewModel.label))
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: .example, item: .example)
    }
}
