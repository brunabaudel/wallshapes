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
    internal var btndelete: UIButton?
    internal var isDeleteActive: Bool?
    internal var selectedIndex: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView = UIView(frame: frame)
        self.btndelete = UIButton()
        self.selectBorder = UIView()
        self.tempView = UIView()
        self.selectedIndex = 0
        self.isDeleteActive = false
        self.isSelected = false
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
