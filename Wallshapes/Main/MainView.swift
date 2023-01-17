//
//  MainView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 29/11/2022.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var viewModel = ViewModel()

    @State private var isShowAlert = false
    @State private var isShowView = false
    @State private var isValid = false
    @State private var name = ""
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                NavigationLink(destination: WallshapesView(wallshape: Wallshape(name: name)), isActive: $isShowView) {
                    EmptyView()
                }
                
                GridView()
                    .environmentObject(viewModel)
            }
            .navigationTitle("Wallshapes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        name = ""
                        isShowAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.reload()
            }
            .alert("Wallshape", isPresented: $isShowAlert) {
                TextField("Wallshape name", text: $name)

                Button("Cancel") {}
                
                Button("Ok") {
                    if name.count >= 1 {
                        isShowView = true
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

@MainActor
class ViewModel: ObservableObject {
    @Published var wallshapes = [Wallshape]()
    
    public func reload() {
        withAnimation {
            wallshapes = ModelControl.recoverAll()
        }
    }
    
    public func delete(wallshape: Wallshape) {
        withAnimation {
            FileControl.deleteFiles(fileName: wallshape.fileName, exts: "json", "png")
            wallshapes = wallshapes.filter { $0 !== wallshape }
        }
    }
    
    public func rename(wallshape: Wallshape) {
        withAnimation {
            FileControl.deleteFiles(fileName: wallshape.fileName, exts: "json", "png")
            wallshapes = wallshapes.filter { $0 !== wallshape }
        }
    }
}
