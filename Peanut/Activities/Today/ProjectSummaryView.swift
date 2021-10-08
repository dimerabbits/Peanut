//
//  ProjectSummaryView.swift
//  Peanut
//
//  Created by Adam on 9/1/21.
//

import SwiftUI

struct ProjectSummaryView: View {
    @ObservedObject var project: Project

    var body: some View {
        NavigationLink(destination: EditProjectView(project: project)) {
            CustomProgressView(project: project)
        }
        .frame(width: 160)
        .offset(y: 14)
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(10)
        .shadow(radius: 1, y: 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(project.label)
    }

    func preview(for project: Project) -> some View {
        VStack(alignment: .center) {
            CustomProgressView(project: Project.example)
        }
    }
}

struct GaugeProgressStyle: ProgressViewStyle {
    @ObservedObject var project: Project

    var trimAmount = 0.7
    var strokeWidth = 12.0
    let formatter = NumberFormatter()

    var rotation: Angle {
        Angle(radians: .pi * (1 - trimAmount)) + Angle(radians: .pi / 2)
    }

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        formatter.numberStyle = .percent
        let percentage = formatter.string(from: fractionCompleted as NSNumber) ?? "0%"

        return ZStack {
            Circle()
                .rotation(rotation)
                .trim(from: 0, to: CGFloat(trimAmount))
                .stroke(
                    Color(project.projectColor).opacity(0.5),
                    style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))

            Circle()
                .rotation(rotation)
                .trim(from: 0, to: CGFloat(trimAmount * fractionCompleted))
                .stroke(
                    Color(project.projectColor),
                    style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))

            VStack(alignment: .center) {
                Text("\(project.projectItems.count) items")
                    .frame(width: 80)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .offset(y: -2)

                Text(project.projectTitle)
                    .frame(width: 110)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .accentColor(Color(project.projectColor))
                    .lineLimit(1)

                Text(percentage)
                    .frame(width: 80)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .accentColor(Color(project.projectColor)).opacity(0.5)
                    .offset(y: 6)
            }
        }
    }
}

struct ProjectSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectSummaryView(project: .example)
            .frame(height: 130)
            .previewLayout(.fixed(width: 400, height: 200))
        ProjectSummaryView(project: .example)
            .frame(height: 130)
            .previewLayout(.fixed(width: 400, height: 200))
            .preferredColorScheme(.dark)
        CustomProgressView(project: .example)
            .frame(height: 130)
            .previewLayout(.fixed(width: 400, height: 200))
        TapProgressView()
            .frame(height: 130)
            .previewLayout(.fixed(width: 400, height: 200))
        TodayView(persistenceController: .preview)
            .previewLayout(.fixed(width: 400, height: 300))
    }
}

struct CustomProgressView: View {
    @ObservedObject var project: Project

    var body: some View {
        ProgressView(value: project.completionAmount)
            .progressViewStyle(GaugeProgressStyle(project: project))
            .frame(width: 140)

    }
}

struct TapProgressView: View {
    @State private var progress = 0.2

    var body: some View {
        ProgressView("Label", value: progress, total: 1.0)
            .progressViewStyle(GaugeProgressStyle(project: .example))
            .onTapGesture {
                if progress < 1 {
                    withAnimation {
                        progress += 0.2
                    }
                }
            }
    }
}
