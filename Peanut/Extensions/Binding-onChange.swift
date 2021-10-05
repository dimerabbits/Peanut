//
//  Binding-OnChange.swift
//  Binding-OnChange
//
//  Created by Adam on 8/31/21.
//

import SwiftUI
import Foundation

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
