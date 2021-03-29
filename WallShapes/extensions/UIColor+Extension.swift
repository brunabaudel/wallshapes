//
//  UIColor+Extension.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

extension UIColor {
    internal var hue: CGFloat {
        return getHSBAComponents(self).0
    }
    
    internal var saturation: CGFloat {
        return getHSBAComponents(self).1
    }
    
    internal var brightness: CGFloat {
        return getHSBAComponents(self).2
    }
    
    internal var alpha: CGFloat {
        return getHSBAComponents(self).3
    }
    
    internal class var random: Self {
        let red = CGFloat.random(in: 0..<1)
        let green = CGFloat.random(in: 0..<1)
        let blue = CGFloat.random(in: 0..<1)
        let alpha = CGFloat(1)
        return Self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    fileprivate func getHSBAComponents(_ color: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var hue, saturation, brightness, alpha : CGFloat
        (hue, saturation, brightness, alpha) = (0.0, 0.0, 0.0, 0.0)
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue, saturation, brightness, alpha)
    }
}
