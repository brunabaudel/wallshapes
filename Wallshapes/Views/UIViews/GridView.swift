//
//  GridView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 06/01/2023.
//

import SwiftUI

struct GridView: View {
    
    @EnvironmentObject private var viewModel: ViewModel
        
    @State private var wallshape: Wallshape?
    @State private var showingAlert = false
    @State private var isValid = false
    @State private var name = ""
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, alignment: .center) {
                ForEach(viewModel.wallshapes) { item in
                    NavigationLink(destination: WallshapesView(wallshape: item)) {
                        ItemGridView(item: item)
                    }
                    .padding(4)
                    .contextMenu {
                        Button(role: .destructive, action: {
                            viewModel.delete(wallshape: item)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .padding()
    }
}
