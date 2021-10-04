//
//  AboutView.swift
//  AboutView
//
//  Created by Adam on 9/4/21.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentation

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(About.allPolicy) { about in
                    Text(about.policy)
                        .padding()
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 20) {
                    Divider()
                    Button("Done") {
                        presentation.wrappedValue.dismiss()
                    }
                }
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Peanut & Privacy")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
