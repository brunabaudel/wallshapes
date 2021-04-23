//
//  WallshapeData.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/16/21.
//

import UIKit

struct WallshapeData: Codable {
    var name: String
    var size: String
    var backgroundColor: [ColorData]
    var shapes: [ShapeData]?
}

struct ShapeData: Codable {
    var shapeType: String
    var layerType: String
    var z: Int
    var x: Float
    var y: Float
    var height: Float
    var width: Float
    var layerColors: [ColorData]
    var alpha: Float?
    var shadowRadius: Float?
    var polygonSides: Float?
}

struct ColorData: Codable {
    var hue: Float
    var saturation: Float
    var brightness: Float
    var alpha: Float
}
