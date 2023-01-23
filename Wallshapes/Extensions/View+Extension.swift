//
//  View+Extension.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 23/01/2023.
//

import SwiftUI

extension View {
    func textFieldAlert(isShowing: Binding<Bool>, text: Binding<String>, title: String, placeholder: String, okAction: @escaping () -> ()) -> some View {
        TextFieldAlert(isShowing: isShowing, text: text, presenting: self, title: title, placeholder: placeholder, okAction: okAction)
    }
}
