//
//  ProjectHeaderView.swift
//  Peanut
//
//  Created by Adam on 8/31/21.
//

import SwiftUI

struct ProjectHeaderView: View {
    @ObservedObject var project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .bottom) {
                NavigationLink(
                    destination: EditProjectView(project: project)) {
                        Text("**\(project.projectTitle)**")
                            .foregroundColor(Color(project.projectColor))
                            .font(.subheadline)
                            .lineLimit(1)

                        Image(systemName: "ellipsis.circle")
                            .symbolRenderingMode(.hierarchical)
                            .font(.callout)
                            .foregroundColor(Color(project.projectColor))
                    }
            }
            ProgressView(value: project.completionAmount)
                .accentColor(Color(project.projectColor))
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("Edit project")
        .accessibilityAddTraits(.isButton)
        .textSelection(.enabled)
    }
}

struct ProjectHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectHeaderView(project: Project.example)
    }
}
