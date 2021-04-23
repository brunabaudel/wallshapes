//
//  WallshapeModelHandler.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/16/21.
//

import UIKit

final class WallshapeModelHandler {
    static private let dirName = "wallshape"
    static private let dirExt = "json"
    
    static public func store(wallshape: Wallshape) {
        let size = wallshape.size.rawValue
        let backgroundColor = cgcolorToColordata(wallshape.backgroundColors)
        let shapes = shapeToShapedata(wallshape.shapes)
        let wallshapeData = WallshapeData(name: dirName, size: size, backgroundColor: backgroundColor, shapes: shapes)
        guard let data = JsonControl.encodeParse(object: wallshapeData) else { return }
        guard let string = String(data: data, encoding: .utf8) else { return }
        let url = FileControl.findURL(fileName: dirName, ext: dirExt)
        FileControl.write(url: url, content: string)
    }
    
    static public func restore() -> Wallshape? {
        let url = FileControl.findURL(fileName: dirName, ext: dirExt)
        guard let wallshapeData = JsonControl.decodeParse(url: url, type: WallshapeData.self) else { return nil }
        guard let size = WallshapeSize(rawValue: wallshapeData.size) else { return nil }
        let backgroundColors = colordataToCGColor(wallshapeData.backgroundColor)
        let shapes = shapedataToShape(wallshapeData.shapes)
        let wallshape = Wallshape(backgroundColors: backgroundColors, shapes: shapes, size: size)
        return wallshape
    }
}

extension WallshapeModelHandler {
    
    //MARK: - Write to JSON
    
    static private func cgcolorToColordata(_ cgColors: [CGColor]?) -> [ColorData] {
        guard let cgColors = cgColors else { return [] }
        var colorsData: [ColorData] = []
        for c in cgColors {
            let uicolor = UIColor(cgColor: c).getHSBAComponents()
            let color = ColorData(
                hue: Float(uicolor.hue),
                saturation: Float(uicolor.saturation),
                brightness: Float(uicolor.brightness),
                alpha: Float(uicolor.alpha)
            )
            colorsData.append(color)
        }
        return colorsData
    }
    
    static private func shapeToShapedata(_ shapes: [Shape]?) -> [ShapeData] {
        guard let shapes = shapes else { return [] }
        var shapesData: [ShapeData] = []
        for s in shapes {
            let shape = ShapeData(
                shapeType: s.type?.rawValue ?? "",
                layerType: calayerToString(layerType: s.layerType),
                z: s.zPosition,
                x: Float(s.origin.x),
                y: Float(s.origin.y),
                height: Float(s.size.width),
                width: Float(s.size.height),
                layerColors: cgcolorToColordata(s.layerColors),
                alpha: Float(s.alpha),
                shadowRadius: Float(s.shadowRadius),
                polygonSides: Float(s.polygon)
            )
            shapesData.append(shape)
        }
        return shapesData
    }
    
    // "gradientLayer" or "shapelayer"
    static private func calayerToString(layerType: CALayer.Type) -> String {
        if layerType == CAGradientLayer.self {
            return "gradientlayer"
        }
        return "shapelayer"
    }
    
    //MARK: - Restore from JSON
    
    static private func colordataToCGColor(_ colors: [ColorData]?) -> [CGColor] {
        guard let colors = colors else {return [] }
        var cgColors: [CGColor] = []
        for c in colors {
            let color = UIColor(
                hue: CGFloat(c.hue),
                saturation: CGFloat(c.saturation),
                brightness: CGFloat(c.brightness),
                alpha: CGFloat(c.alpha)
            )
            cgColors.append(color.cgColor)
        }
        return cgColors
    }
    
    static private func shapedataToShape(_ shapesData: [ShapeData]?) -> [Shape] {
        guard let shapesData = shapesData else { return [] }
        var shapes: [Shape] = []
        for s in shapesData {
            let shape = Shape()
            shape.zPosition = s.z
            shape.type = ShapeType(rawValue: s.shapeType)
            shape.origin = CGPoint(x: CGFloat(s.x), y: CGFloat(s.y))
            shape.size = CGSize(width: CGFloat(s.width), height: CGFloat(s.height))
            shape.layerColors = colordataToCGColor(s.layerColors)
            shape.alpha = CGFloat(s.alpha ?? 1)
            shape.shadowRadius = CGFloat(s.shadowRadius ?? 0)
            shape.polygon = CGFloat(s.polygonSides ?? 0)
            shape.layerType = stringToCALayer(layerType: s.layerType)
            shapes.append(shape)
        }
        return shapes
    }
    
    // "gradientLayer" or "shapelayer"
    static private func stringToCALayer(layerType: String) -> CALayer.Type {
        if layerType == "gradientlayer" {
            return CAGradientLayer.self
        }
        return CAShapeLayer.self
    }
}
