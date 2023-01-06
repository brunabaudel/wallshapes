//
//  ContentView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 29/11/2022.
//

import SwiftUI

struct MainGridView: View {
    
    @State var wallshapes: [Wallshape] = []
    @State private var showingAlert = false
    @State private var isShowView = false
    @State private var isValid = false
    @State private var name = ""

    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                NavigationLink(destination: WallshapesView(wallshape: Wallshape(name: name)), isActive: $isShowView) {
                    EmptyView()
                }
                
                LazyVGrid(columns: columns, alignment: .center) {
                    ForEach(wallshapes) { item in
                        NavigationLink(destination: WallshapesView(wallshape: item)) {
                            ItemGridView(item: item)
                        }
                        .padding(4)
                    }
                }
                .padding()
            }
            .navigationTitle("Wallshapes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAlert.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .alert("Wallshape", isPresented: $showingAlert) {
            TextField("Wallshape name", text: $name.onChange(nameChanged))
                .disabled(isValid)
            
            Button("Ok") {
                if name.count > 1 {
                    isShowView = true
                }
            }
        }
        .onAppear {
            self.wallshapes = ModelControl.recoverAll()
        }
    }
    
    func nameChanged(to value: String) {
        isValid = value.count > 10
        print("Name changed to \(name)!", isValid)
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
