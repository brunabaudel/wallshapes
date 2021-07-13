//
//  ShapeView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class ShapeView: UIView {
    internal var shape: Shape?

    init(shape: Shape) {
        self.shape = shape
        super.init(frame: shape.frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
