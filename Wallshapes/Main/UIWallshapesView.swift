//
//  UIWallshapesView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 29/11/2022.
//

import SwiftUI
import UIKit

struct WallshapesView: View {
    @State var wallshape: Wallshape
    @Environment(\.scenePhase) var scenePhase
    
    @State var wallshapesViewController: WallshapesViewController? = WallshapesViewController()
    
    var body: some View {
        UIWallshapesView(wallshape: wallshape, wallshapesViewController: wallshapesViewController ?? WallshapesViewController())
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    wallshapesViewController?.saveFileHandle(completion: {})
                    wallshapesViewController = nil
                }
            }
            .onAppear {
                wallshapesViewController = WallshapesViewController()
                
            }
    }
}

struct UIWallshapesView: UIViewControllerRepresentable {
    var wallshape: Wallshape
    let wallshapesViewController: WallshapesViewController

    func makeUIViewController(context: Context) -> WallshapesNavigationController {
        wallshapesViewController.wallshape = wallshape
        let wallshapesNavigationController = WallshapesNavigationController(rootViewController: wallshapesViewController)
        wallshapesNavigationController.doneAction = context.environment.dismiss.callAsFunction
        return wallshapesNavigationController
    }

    func updateUIViewController(_ viewController: WallshapesNavigationController, context: Context) {}
}
