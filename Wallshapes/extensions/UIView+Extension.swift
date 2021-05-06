//
//  UIView+Extension.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/4/21.
//

import UIKit

extension UIView {
    internal var firstSublayer: CALayer? {
        guard let sublayers = layer.sublayers, sublayers.count > 0 else {return nil}
        return sublayers.first
    }
    
    func showNavigation() {
        guard let parent = parentViewController() else {return}
        parent.navigationController?.navigationBar.isHidden = !(parent.navigationController?.navigationBar.isHidden ?? false)
    }
    
    private func parentViewController() -> UIViewController? {
        return sequence(first: self) { $0.next }
            .first(where: { $0 is UIViewController })
            .flatMap { $0 as? UIViewController }
    }
    
    func fadeIn(_ duration: TimeInterval, _ completionHandler: ((Bool) -> Void)? = nil) {
        Self.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completionHandler)
    }
    
    func fadeOut(_ duration: TimeInterval, _ completionHandler: ((Bool) -> Void)? = nil) {
        Self.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: completionHandler)
    }
}
