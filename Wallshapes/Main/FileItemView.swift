//
//  FileItemView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 29/11/2022.
//

import SwiftUI

struct FileItemView: View {
    
    @State var array: [Int]
    var at: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Image(systemName: "heart")
                    .font(.largeTitle)
                    .padding(.vertical, 8)
                Text("title")
            }
            .padding(32)
            .background(.gray.opacity(0.4))
            .cornerRadius(15)
            
            Button(action: {
                withAnimation { () -> () in
                    print("removed", at)
                    self.array.remove(at: at)
                }
            }){
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .frame(width: 35, height: 35)
                    .background(.red)
                    .cornerRadius(100)
            }
            .padding(-8)
        }
        .transition(AnyTransition.scale)
    }
}
