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

final class Wallshape: Identifiable {
    let id = UUID()
    var name: String = ""
    var fileName: String = ""
    var modifiedAt: Date?
    var thumbnail: Data?
    var backgroundColors: [UIColor] = []
    var shapes: [Shape] = []

    init(name: String, modifiedAt: Date, backgroundColors: [UIColor], shapes: [Shape]) {
        self.name = name
        self.modifiedAt = modifiedAt
        self.backgroundColors = backgroundColors
        self.shapes = shapes
    }
    
    convenience init(name: String, fileName: String, modifiedAt: Date, thumbnail: Data, backgroundColors: [UIColor], shapes: [Shape]) {
        self.init(name: name, modifiedAt: modifiedAt, backgroundColors: backgroundColors, shapes: shapes)
        self.thumbnail = thumbnail
        self.fileName = fileName
    }
    
    init(name: String) {
        self.name = name
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
