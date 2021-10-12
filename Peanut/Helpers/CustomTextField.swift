//
//  CustomTextField.swift
//  Peanut
//
//  Created by Adam on 9/24/21.
//

import SwiftUI

struct CustomTextField: View {

  let title: LocalizedStringKey

  @Binding var text: String
  @State private var isEditing: Bool = false

  private var isClear: Bool {
    return self.isEditing && !self.text.isEmpty
  }

  init(_ title: LocalizedStringKey, text: Binding<String>) {
    self.title = title
    self._text = text
  }

  var body: some View {
    ZStack(alignment: .trailing) {
      TextField(self.title,
           text: self.$text) { isEditing in
        self.isEditing = isEditing
      } onCommit: {
        self.isEditing = false
      }
      .padding(.trailing, self.isClear ? 18 : 0)

      if self.isClear {
        Button {
          self.text = ""
        } label: {
          Image(systemName: "multiply.circle.fill").foregroundColor(.secondary)
        }
        .buttonStyle(PlainButtonStyle())
      }
    }
    .frame(alignment: .trailing)
  }
}
