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
            guard let shapelayer = self as? CAShapeLayer else {return nil}
            return shapelayer.path
        case is CAGradientLayer.Type:
            guard let gradlayer = self as? CAGradientLayer,
                  let mask = gradlayer.mask,
                  let shapelayer = mask as? CAShapeLayer else {return nil}
            return shapelayer.path
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

extension CATransaction {
    class func removeAnimation(completion: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        completion()
        CATransaction.commit()
    }
}
