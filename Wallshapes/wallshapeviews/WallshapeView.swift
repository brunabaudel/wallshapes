//
//  WallshapeView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class WallshapeView: UIView {
    internal var contentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView = UIView(frame: frame)
        self.backgroundColor = .init(white: 0.15, alpha: 1)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension WallshapeView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
                            -> Bool {
        if gestureRecognizer is UILongPressGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}
