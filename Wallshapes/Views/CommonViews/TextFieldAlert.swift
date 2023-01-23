//
//  TextFieldAlert.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 23/01/2023.
//

import SwiftUI

struct TextFieldAlert<Presenting>: View where Presenting: View {
    @Environment(\.colorScheme) var colorScheme
    
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
                        .padding(.vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle ())
                    
                    Divider()
                    
                    HStack {
                        Button (action: {
                            withAnimation {
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
                .background(colorScheme == .dark ? Color.darkBackground : Color.lightBackground)
                .cornerRadius(15)
                .frame(
                    width: deviceSize.size.width*0.7,
                    height: deviceSize.size.height*0.7
                )
                .shadow(radius: 1)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}
