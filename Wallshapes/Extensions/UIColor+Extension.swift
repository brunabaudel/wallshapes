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

    func getHSBAComponents() -> HSBAColor {
        var hsba = HSBAColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.0)
        self.getHue(&hsba.hue, saturation: &hsba.saturation, brightness: &hsba.brightness, alpha: &hsba.alpha)
        return hsba
    }
}

struct HSBAColor {
    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    var alpha: CGFloat
}
