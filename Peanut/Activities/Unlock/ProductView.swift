//
//  ProductView.swift
//  ProductView
//
//  Created by Adam on 9/2/21.
//

import SwiftUI
import StoreKit

struct ProductView: View {
    @EnvironmentObject var unlockManager: UnlockManager
    let product: SKProduct

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("**Get Unlimited Projects**")
                    .font(.headline)
                    .padding(.top)
                    .shadow(radius: 1, y: 1)

                Text("""
                    You can add three projects for free, or pay \(product.localizedPrice) to add unlimited projects.

                    If you already bought the unlock on another device, press Restore Purchases.
                    """)

                Button("Buy: \(product.localizedPrice)", action: unlock)
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                    .padding(.top)

                Button("Restore Purchases", action: unlockManager.restore)
                    .buttonStyle(.borderless)
                    .font(.footnote)
            }
        }
    }

    func unlock() {
        unlockManager.buy(product: product)
    }
}
