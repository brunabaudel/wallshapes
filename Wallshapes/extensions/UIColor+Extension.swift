//
//  UIColor+Extension.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

extension UIColor {
    internal var hue: CGFloat {
        return self.getHSBAComponents().hue
    }
    
    internal var saturation: CGFloat {
        return self.getHSBAComponents().saturation
    }
    
    internal var brightness: CGFloat {
        return self.getHSBAComponents().brightness
    }
    
    internal var alpha: CGFloat {
        return self.getHSBAComponents().alpha
    }
    
    internal class var random: Self {
        let red = CGFloat.random(in: 0..<1)
        let green = CGFloat.random(in: 0..<1)
        let blue = CGFloat.random(in: 0..<1)
        let alpha = CGFloat(1)
        return Self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public func getHSBAComponents() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue, saturation, brightness, alpha: CGFloat
        (hue, saturation, brightness, alpha) = (0.0, 0.0, 0.0, 0.0)
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue, saturation, brightness, alpha)
    }
}
