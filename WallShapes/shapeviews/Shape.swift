//
//  Shape.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

enum ShapeType {
    case circle, rectangle, triangle
}

class Shape {
    var type: ShapeType?
    var shapeLayerColor: CGColor?
    var gradientLayerColors: [CGColor]?
    var path: CGPath?
    var shapeLayer: CAShapeLayer?
    var gradientLayer: CAGradientLayer?
    var alpha: CGFloat?
    var shadowRadius: CGFloat?
}
