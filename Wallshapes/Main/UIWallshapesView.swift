//
//  UIWallshapesView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 29/11/2022.
//

import SwiftUI
import UIKit

struct WallshapesView: View {
    var body: some View {
        UIWallshapesView()
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
    }
}

struct UIWallshapesView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> WallshapesNavigationController {
        let wallshapesViewController = WallshapesNavigationController(rootViewController: WallshapesViewController())
        return wallshapesViewController
    }

    func updateUIViewController(_ viewController: WallshapesNavigationController, context: Context) {
        viewController.doneAction = context.environment.dismiss.callAsFunction
    }
}
