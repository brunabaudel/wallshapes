//
//  ShapeView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class ShapeView: UIView {
    internal var shape: Shape?

    init(frame: CGRect, shape: Shape) {
        super.init(frame: frame)
        self.shape = shape
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
