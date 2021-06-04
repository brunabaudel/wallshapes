//
//  AppDelegate.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var initialViewController: WallshapesViewController!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        initialViewController = WallshapesViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = WallshapesNavigationController(rootViewController: initialViewController)
        window?.makeKeyAndVisible()

        return true
    }

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions
                        launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FileControl.copyToDocuments(fileName: "wallshape", ext: "json")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        initialViewController.saveFileHandle()
    }
}

// MARK: UISceneSession Lifecycle

@available(iOS 13.0, *)
extension AppDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
