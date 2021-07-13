//
//  ModelControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/21/21.
//

import UIKit

final class ModelControl {
    private var size: WallshapeSize = .normal
    private var shapeViews: [ShapeView] = []
    private var backgroundColors: [UIColor] = []

    // MARK: - Get/Set data from json

    public func recover() -> Wallshape? {
        return WallshapeModelHandler.restore()
    }

    public func save() {
        return WallshapeModelHandler.store(wallshape: wallshape())
    }

    // MARK: - Get data from user

    public func updateBackgroundColors(_ colors: [UIColor]) {
        self.backgroundColors = colors
    }

    public func addShapeViews(_ shapeViews: [ShapeView]) {
        self.shapeViews = shapeViews
    }

    public func wallshapeSize(_ size: WallshapeSize) {
        self.size = size
    }
}

extension ModelControl {
    private func wallshape() -> Wallshape {
        return Wallshape(backgroundColors: self.backgroundColors, shapes: self.shapes(), size: self.size)
    }

    private func shapes() -> [Shape] {
        var shapes: [Shape] = []
        shapeViews.enumerated().forEach { (idx, shapeView) in
            guard let shape = shapeView.shape else { return }
            shape.zPosition = idx
            shapes.append(shape)
        }
        return shapes
    }
}
