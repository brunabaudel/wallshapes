//
//  WallshapeModel.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

enum ShapeType: String {
    case circle = "circle"
    case rectangle = "rectangle"
    case triangle = "triangle"
    case polygon = "polygon"
}

enum WallshapeSize: String {
    case small = "small"
    case medium = "medium"
    case normal = "normal"
}

class Wallshape {
    var size: WallshapeSize = .normal
    var backgroundColors: [CGColor] = []
    var shapes: [Shape] = []
    
    init(backgroundColors: [CGColor], shapes: [Shape], size: WallshapeSize) {
        self.size = size
        self.backgroundColors = backgroundColors
        self.shapes = shapes
    }
}

class Shape {
    var zPosition: Int = 0 //TODO: use this property in future!
    var type: ShapeType?
    var size: CGSize = CGSize.zero
    var origin: CGPoint = CGPoint.zero
    var layerColors: [CGColor]? = []
    var layerType: CALayer.Type = CAShapeLayer.self
    var shapeLayer: CAShapeLayer?
    var gradientLayer: CAGradientLayer?
    var alpha: CGFloat = 1.0
    var shadowRadius: CGFloat = 0.0
    var polygon: CGFloat = 0.0
}
