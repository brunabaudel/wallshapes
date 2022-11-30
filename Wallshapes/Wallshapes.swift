//
//  Wallshapes.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 29/11/2022.
//

import SwiftUI

@main
struct jhbjApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainGridView()
        }
    }
}
