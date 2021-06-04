//
//  SceneDelegate.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var initialViewController: WallshapesViewController!

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        initialViewController = WallshapesViewController()
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = WallshapesNavigationController(rootViewController: initialViewController)
        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        initialViewController?.saveFileHandle()
    }
}
