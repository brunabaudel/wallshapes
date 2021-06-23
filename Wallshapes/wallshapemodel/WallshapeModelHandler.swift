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
        var shapes = shapeToShapedata(wallshape.shapes)
        defer {
            backgroundColor = []
            shapes = []
        }
        let backgroundColor = uicolorToColordata(wallshape.backgroundColors)
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
        var shapes = shapedataToShape(wallshapeData.shapes)
        defer {
            backgroundColors = []
            shapes = []
        }
        let backgroundColors = colordataToUIColor(wallshapeData.backgroundColor)
        let wallshape = Wallshape(backgroundColors: backgroundColors, shapes: shapes, size: size)
        return wallshape
    }
}

extension WallshapeModelHandler {

    // MARK: - Write to JSON

    static private func uicolorToColordata(_ colors: [UIColor]?) -> [ColorData] {
        guard let colors = colors else { return [] }
        var colorsData: [ColorData] = []
        for clr in colors {
            let uicolor = clr.getHSBAComponents()
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
        for shp in shapes {
            let shape = ShapeData(
                shapeType: shp.type?.rawValue ?? "",
                layerType: calayerToString(layerType: shp.layerType),
                z: shp.zPosition,
                x: Float(shp.frame.origin.x),
                y: Float(shp.frame.origin.y),
                height: Float(shp.frame.size.width),
                width: Float(shp.frame.size.height),
                layerColors: uicolorToColordata(shp.layerColors),
                alpha: Float(shp.alpha),
                shadowRadius: Float(shp.shadowRadius),
                polygonSides: Float(shp.polygon)
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

    // MARK: - Restore from JSON

    static private func colordataToUIColor(_ colors: [ColorData]?) -> [UIColor] {
        guard let colors = colors else {return [] }
        var uicolors: [UIColor] = []
        for clr in colors {
            let color = UIColor(
                hue: CGFloat(clr.hue),
                saturation: CGFloat(clr.saturation),
                brightness: CGFloat(clr.brightness),
                alpha: CGFloat(clr.alpha)
            )
            uicolors.append(color)
        }
        return uicolors
    }

    static private func shapedataToShape(_ shapesData: [ShapeData]?) -> [Shape] {
        guard let shapesData = shapesData else { return [] }
        var shapes: [Shape] = []
        for sdt in shapesData {
            let shape = Shape()
            shape.zPosition = sdt.z
            shape.type = ShapeType(rawValue: sdt.shapeType)
            shape.frame = CGRect(x: CGFloat(sdt.x), y: CGFloat(sdt.y),
                                 width: CGFloat(sdt.width), height: CGFloat(sdt.height))
            shape.layerColors = colordataToUIColor(sdt.layerColors)
            shape.alpha = CGFloat(sdt.alpha ?? 1)
            shape.shadowRadius = CGFloat(sdt.shadowRadius ?? 0)
            shape.polygon = CGFloat(sdt.polygonSides ?? 0)
            shape.layerType = stringToCALayer(layerType: sdt.layerType)
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
