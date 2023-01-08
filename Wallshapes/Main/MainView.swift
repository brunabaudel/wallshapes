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
                    .foregroundColor(.black)
                    .disabled(name.count > 10)

                Button("Cancel") {}
                
                Button("Ok") {
                    if name.trimmingCharacters(in: .whitespacesAndNewlines)
                        .range(of: "^[a-zA-Z0-9_\\s]*$", options: .regularExpression) != nil && name.count >= 1 {
                        isShowView = true
                    }
                }
            }
        }
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
}
