//
//  View+hideKeyboard.swift
//  Peanut
//
//  Created by Adam on 10/5/21.
//

import SwiftUI
import UIKit

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
