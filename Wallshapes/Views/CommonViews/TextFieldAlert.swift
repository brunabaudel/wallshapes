//
//  TextFieldAlert.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 23/01/2023.
//

import SwiftUI

struct TextFieldAlert<Presenting>: View where Presenting: View {
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isFocused: Bool
    
    @Binding var isShowing: Bool
    @Binding var text: String
    let presenting: Presenting
    let title: String
    let placeholder: String
    let okAction: () -> ()

    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting
                    .disabled(isShowing)
                
                Color.black.opacity(isShowing ? colorScheme == .dark ? 0.5 : 0.2 : 0)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(self.title)
                        .bold()
                    
                    TextField(self.placeholder, text: self.$text)
                        .focused($isFocused)
                        .padding(.vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle ())
                    
                    Divider()
                    
                    HStack {
                        Button (action: {
                            withAnimation {
                                self.isFocused = false
                                self.isShowing = false
                            }
                        }) {
                            Text("Cancel")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        Divider()
                        
                        Button (action: {
                            withAnimation {
                                okAction()
                                self.isFocused = false
                                self.isShowing = false
                            }
                        }) {
                            Text("OK")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 15))
                .frame(
                    width: deviceSize.size.width*0.7,
                    height: deviceSize.size.height*0.7
                )
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}
