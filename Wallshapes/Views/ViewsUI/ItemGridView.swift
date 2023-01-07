//
//  ItemGridView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 29/11/2022.
//

import SwiftUI

struct ItemGridView: View {
    @Environment(\.colorScheme) var colorScheme
    let item: Wallshape
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Image(uiImage: UIImage(data: item.thumbnail ?? Data()) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                Text(item.name)
                    .lineLimit(1)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
        }
        .transition(AnyTransition.scale)
    }
}
