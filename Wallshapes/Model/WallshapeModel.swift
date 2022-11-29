//
//  WallshapeModel.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

enum ShapeType: String {
    case circle, rectangle, triangle, polygon
}

enum WallshapeSize: String {
    case small, medium, normal
}

final class Wallshape {
    var size: WallshapeSize = .normal
    var backgroundColors: [UIColor] = []
    var shapes: [Shape] = []

    init(backgroundColors: [UIColor], shapes: [Shape], size: WallshapeSize) {
        self.size = size
        self.backgroundColors = backgroundColors
        self.shapes = shapes
    }
}

final class Shape {
    var zPosition: Int = 0
    var type: ShapeType?
    var frame: CGRect = CGRect.zero
    var layerColors: [UIColor]? = []
    var layerType: CALayer.Type = CAShapeLayer.self
    var shapeLayer: CAShapeLayer?
    var gradientLayer: CAGradientLayer?
    var alpha: CGFloat = 1.0
    var shadowRadius: CGFloat = 0.0
    var polygon: CGFloat = 0.0
}
