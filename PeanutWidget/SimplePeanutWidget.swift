//
//  SimplePeanutWidget.swift
//  SimplePeanutWidget
//
//  Created by Adam on 9/2/21.
//

import SwiftUI
import WidgetKit

struct PeanutWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack {
            Text("Up next…")
                .font(.title)

            if let item = entry.items.first {
                Text(item.itemTitle)
            } else {
                Text("Nothing!")
            }
        }
    }
}

struct SimplePeanutWidget: Widget {
    let kind: String = "SimplePeanutWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PeanutWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Up next…")
        .description("Your #1 top-priority item.")
        .supportedFamilies([.systemSmall])
    }
}

struct SimplePeanutWidget_Previews: PreviewProvider {
    static var previews: some View {
        PeanutWidgetEntryView(entry: .example)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
