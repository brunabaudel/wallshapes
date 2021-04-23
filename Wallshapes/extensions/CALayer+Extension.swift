//
//  CALayer.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/4/21.
//

import UIKit

extension CALayer {
    
    internal var layerMutableCopy: CGPath? {
        guard let path = layerPath() else {return nil}
        return path.mutableCopy()
    }
    
    func contains(_ location: CGPoint) -> Bool {
        guard let path = layerPath() else {return false}
        return path.contains(location)
    }
    
    func layerPath() -> CGPath? {
        switch type(of: self) {
        case is CAShapeLayer.Type:
            return (self as! CAShapeLayer).path
        case is CAGradientLayer.Type:
            guard let mask = (self as! CAGradientLayer).mask else {return nil}
            return (mask as! CAShapeLayer).path
        default:
            return nil
        }
    }
    
    func isEqualTo(type layer: CALayer.Type) -> Bool {
        if Self.self == layer {
            return true
        }
        return false
    }
}
