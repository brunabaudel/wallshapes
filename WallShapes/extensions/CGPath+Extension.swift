//
//  CGPath+Extension.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/4/21.
//

import UIKit

extension CGPath {
    func translate(_ point: CGPoint) -> CGPath? {
        let bezierPath = UIBezierPath()
        bezierPath.cgPath = self
        bezierPath.apply(CGAffineTransform(translationX: point.x, y: point.y))
        return bezierPath.cgPath
    }
    
    func scale(_ fromSize: CGSize, toSize: CGSize) -> CGPath? {
        let bezierPath = UIBezierPath()
        bezierPath.cgPath = self
        bezierPath.scaleAroundCenter(fromSize, toSize: toSize)
        return bezierPath.cgPath
    }
}

extension UIBezierPath {
    func scaleAroundCenter(_ fromSize: CGSize, toSize: CGSize) {
        let beforeCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        let scaleWidth = (toSize.width / fromSize.width)
        let scaleHeight = (toSize.height / fromSize.height)
        self.apply(CGAffineTransform(scaleX: scaleWidth, y: scaleHeight))
        
        let afterCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let diff = CGPoint(x: beforeCenter.x - afterCenter.x, y: beforeCenter.y - afterCenter.y)
        self.apply(CGAffineTransform(translationX: diff.x, y: diff.y))
    }
}
