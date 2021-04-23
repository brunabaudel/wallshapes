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
}
