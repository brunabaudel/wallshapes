//
//  CGPath+Extension.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/4/21.
//

import UIKit

extension CGPath {
    func translate(_ point: CGPoint) -> CGPath? {
        let bezeirPath = UIBezierPath()
        bezeirPath.cgPath = self
        bezeirPath.apply(CGAffineTransform(translationX: point.x, y: point.y))
        return bezeirPath.cgPath
    }
}
