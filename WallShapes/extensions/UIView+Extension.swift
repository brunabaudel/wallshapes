//
//  UIView+Extension.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/4/21.
//

import UIKit

extension UIView {
    func firstSublayer() -> CALayer? {
        guard let sublayers = layer.sublayers, sublayers.count > 0 else {return nil}
        return sublayers[0].layerByType()
    }
    
    func parentViewController() -> UIViewController? {
        return sequence(first: self) { $0.next }
            .first(where: { $0 is UIViewController })
            .flatMap { $0 as? UIViewController }
    }
}
