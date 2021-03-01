//
//  UIApplication+Extension.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/8/21.
//

import UIKit

extension UIApplication {
    class func window() -> UIWindow? {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {return nil}
        return window
    }
}
