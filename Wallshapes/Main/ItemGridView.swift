//
//  ItemGridView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 29/11/2022.
//

import SwiftUI

struct ItemGridView: View {
    
    @State var item: Wallshape
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Image(uiImage: UIImage(data: item.thumbnail ?? Data()) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                Text(item.name)
                    .lineLimit(2)
            }
            
//            Button(action: {
//                withAnimation { () -> () in
////                    print("removed", at)
////                    self.item.remove(at: at)
//                }
//            }){
//                Image(systemName: "xmark")
//                    .foregroundColor(.white)
//                    .frame(width: 35, height: 35)
//                    .background(.red)
//                    .cornerRadius(100)
//            }
//            .padding(-8)
        }
        .transition(AnyTransition.scale)
    }
}
