//
//  ItemListView.swift
//  ItemListView
//
//  Created by Adam on 9/1/21.
//

import SwiftUI

struct ItemListView: View {
    let title: LocalizedStringKey
    @Binding var items: ArraySlice<Item>

    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            Text(title)
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.top)

            ForEach(items) { item in
                NavigationLink(destination: EditItemView(item: item)) {
                    preview(for: item)
                }
            }
        }
    }

    func preview(for item: Item) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.itemTitle)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if item.itemDetail.isEmpty == false {
                    Text(item.itemDetail)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(Font.callout.weight(.bold))
                .foregroundColor(Color(item.project?.projectColor ?? "AccentColor"))
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(10)
        .shadow(radius: 1, y: 1)
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(persistenceController: .preview)
            .preferredColorScheme(.dark)
        TodayView(persistenceController: .preview)
    }
}
