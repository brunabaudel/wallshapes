//
//  WallshapeView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class WallshapeView: UIView {
    internal var contentView: UIView?
    internal var isSelected: Bool?
    internal var selectBorder: UIView?
    internal var tempView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView = UIView(frame: frame)
        self.selectBorder = UIView()
        self.tempView = UIView()
        self.isSelected = false
        self.backgroundColor = .clear
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