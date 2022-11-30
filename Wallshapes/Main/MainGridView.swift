//
//  ContentView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 29/11/2022.
//

import SwiftUI

struct MainGridView: View {
    
    let wallshapes = [1,2,3,4,5,6,7,8]

    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                
                Text("Wallshapes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                LazyVGrid(columns: columns, alignment: .center) {
                    ForEach(0..<wallshapes.count, id: \.self) { item in
                        NavigationLink(destination: WallshapesView()) {
                            FileItemView(array: wallshapes, at: item)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            }
            .navigationTitle("")
        }
    }
}
