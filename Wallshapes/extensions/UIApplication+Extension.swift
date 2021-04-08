//
//  UIApplication+Extension.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/8/21.
//

import UIKit

extension UIApplication {
    internal class var window: UIWindow? {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {return nil}
        return window
    }
}
