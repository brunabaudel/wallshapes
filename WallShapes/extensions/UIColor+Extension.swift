//
//  UIColor+Extension.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

extension UIColor {
    static func random() -> UIColor {
        let red = CGFloat.random(in: 0..<1)
        let green = CGFloat.random(in: 0..<1)
        let blue = CGFloat.random(in: 0..<1)
//        let alpha = CGFloat.random(in: 0..<1)
        return UIColor.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
