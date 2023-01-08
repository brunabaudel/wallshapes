//
//  UIApplication+Extension.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/8/21.
//

import UIKit

extension UIApplication {
    internal class var window: UIWindow? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first
    }
}
