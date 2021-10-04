//
//  ComplexPeanutWidget.swift
//  ComplexPeanutWidget
//
//  Created by Adam on 9/2/21.
//

import SwiftUI
import WidgetKit

struct PeanutWidgetMultipleEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.sizeCategory) var sizeCategory

    var entry: SimpleEntry

    var items: ArraySlice<Item> {
        let itemCount: Int

        switch widgetFamily {
        case .systemSmall:
            itemCount = 1
        case .systemLarge:
            if sizeCategory < .extraExtraLarge {
                itemCount = 5
            } else {
                itemCount = 4
            }
        default:
            if sizeCategory < .extraLarge {
                itemCount = 3
            } else {
                itemCount = 2
            }
        }

        return entry.items.prefix(itemCount)
    }

    var body: some View {
        VStack(spacing: 5) {
            ForEach(items) { item in
                HStack {
                    Color(item.project?.color ?? "LightBlue")
                        .frame(width: 5)
                        .clipShape(Capsule())

                    VStack(alignment: .leading) {
                        Text(item.itemTitle)
                            .font(.headline)
                            .layoutPriority(1)

                        if let projectTitle = item.project?.title {
                            Text(projectTitle)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
    }
}

struct ComplexPeanutWidget: Widget {
    let kind: String = "ComplexPeanutWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PeanutWidgetMultipleEntryView(entry: entry)
        }
        .configurationDisplayName("Up next…")
        .description("Your most important item.")
    }
}

struct ComplexPeanutWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PeanutWidgetMultipleEntryView(entry: .example)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            PeanutWidgetMultipleEntryView(entry: .example)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            PeanutWidgetMultipleEntryView(entry: .example)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
