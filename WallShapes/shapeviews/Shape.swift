//
//  Shape.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

enum ShapeType {
    case circle, rectangle, triangle, polygon
}

class Shape {
    var type: ShapeType?
    var size: CGSize = CGSize.zero
    var shapeLayerColor: CGColor?
    var gradientLayerColors: [CGColor]?
    var path: CGPath?
    var shapeLayer: CAShapeLayer?
    var gradientLayer: CAGradientLayer?
    var alpha: CGFloat = 1.0
    var shadowRadius: CGFloat = 0.0
    var polygon: CGFloat = 0.0
}
