//
//  WelcomeView.swift
//  WelcomeView
//
//  Created by Adam on 9/4/21.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var presentingSheet = false

    var body: some View {
        VStack {
            VStack(spacing: 45) {
                Text("**Welcome to Peanut**")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .shadow(radius: 1, y: 1)
                    .padding()

                ForEach(Feature.allFeatures) { feature in
                    HStack(alignment: .center, spacing: 1) {
                        Image(systemName: feature.image)
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: 60)
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading) {
                            Text(feature.title)
                                .font(.headline)

                            Text(feature.description)
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()

            Image(systemName: "network.badge.shield.half.filled")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.accentColor)
                .font(.title2)

            Button("About Peanut & Privacy…") {
                self.presentingSheet = true
            }
            .padding()
            .frame(maxWidth: .infinity)
            .font(.footnote)

            Button(action: close) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

        }
        .sheet(isPresented: $presentingSheet) {
            AboutView()
        }
        .padding()
    }

    func close() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
        WelcomeView()
            .preferredColorScheme(.dark)
    }
}
