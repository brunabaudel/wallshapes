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
    
    var body: some View {
        UIWallshapesView(wallshape: wallshape)
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
    }
}

struct UIWallshapesView: UIViewControllerRepresentable {
    
    var wallshape: Wallshape

    func makeUIViewController(context: Context) -> WallshapesNavigationController {
        let wallshapesViewController = WallshapesViewController()
        wallshapesViewController.wallshape = wallshape
        let wallshapesNavigationController = WallshapesNavigationController(rootViewController: wallshapesViewController)
        wallshapesNavigationController.doneAction = context.environment.dismiss.callAsFunction
        return wallshapesNavigationController
    }

    func updateUIViewController(_ viewController: WallshapesNavigationController, context: Context) {}
}
