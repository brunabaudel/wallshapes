//
//  LayoutShapeView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 7/30/21.
//

import UIKit

final class LayoutShapeView {
    
    private var menuShapeControl: MenuShapeControl?
    
    init(menu: MenuShapeControl) {
        self.menuShapeControl = menu
    }
    
    public func createPath(_ shapeview: ShapeView, by type: ShapeType, _ isSelected: Bool = false) {
        guard let shape = shapeview.shape else {return}
        shape.type = type
        switch type {
        case ShapeType.circle:
            self.createPathCircle(shapeview, isSelected)
        case ShapeType.rectangle:
            self.createPathRectangle(shapeview, isSelected)
        case ShapeType.triangle:
            self.createPathTriangle(shapeview, isSelected)
        case ShapeType.polygon:
            self.createPathPolygon(shapeview, isSelected)
        }
    }
    
    private func tempViewFrame() -> CGRect {
        guard let menu = self.menuShapeControl,
              let view = menu.wallshapeview, let tempview = view.tempView else {return CGRect.zero}
        return tempview.frame
    }

    private func createPathCircle(_ shapeview: ShapeView, _ isSelected: Bool = false) {
        guard let shape = shapeview.shape else {return}
        shape.polygon = 0
        let frame = isSelected ? tempViewFrame() : shape.frame
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: frame.origin.x + (frame.size.width)/2,
                                        y: frame.origin.y + (frame.size.height)/2),
                    radius: frame.size.width/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
        path.close()
        changeShapeLayer(shapeview, path, isSelected)
    }

    private func createPathRectangle(_ shapeview: ShapeView, _ isSelected: Bool = false) {
        guard let shape = shapeview.shape else {return}
        shape.polygon = 0
        let frame = isSelected ? tempViewFrame() : shape.frame
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.origin.x, y: frame.origin.y))
        path.addLine(to: CGPoint(x: frame.origin.x, y: frame.origin.y + frame.size.height))
        path.addLine(to: CGPoint(x: frame.origin.x + frame.size.width,
                                 y: frame.origin.y + frame.size.height))
        path.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y))
        path.close()
        changeShapeLayer(shapeview, path, isSelected)
    }

    private func createPathTriangle(_ shapeview: ShapeView, _ isSelected: Bool = false) {
        guard let shape = shapeview.shape else {return}
        shape.polygon = 0
        let frame = isSelected ? tempViewFrame() : shape.frame
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width/2 + frame.origin.x, y: frame.origin.y))
        path.addLine(to: CGPoint(x: frame.origin.x, y: frame.size.height + frame.origin.y))
        path.addLine(to: CGPoint(x: frame.size.width + frame.origin.x,
                                 y: frame.size.height + frame.origin.y))
        path.close()
        changeShapeLayer(shapeview, path, isSelected)
    }

    private func changeShapeLayer(_ shapeview: ShapeView, _ path: UIBezierPath, _ isSelected: Bool) {
        guard let shape = shapeview.shape,
              let color = shape.layerColors?.first,
              let shapeLayer = createShapeLayers(shapeview, path, color: color, isSelected) else {return}
        if shape.layerType.isEqual(CAShapeLayer.self) {
            replaceShapeLayer(shapeview, shapeLayer)
        }
        if shape.layerType.isEqual(CAGradientLayer.self) {
            replaceGradientLayer(shapeview, shapeLayer)
        }
    }

    private func replaceShapeLayer(_ shapeview: ShapeView, _ shapeLayer: CAShapeLayer) {
        self.replaceLayer(shapeview, shapeLayer)
    }

    private func replaceGradientLayer(_ shapeview: ShapeView, _ shapeLayer: CAShapeLayer) {
        guard let shape = shapeview.shape, let colors = shape.layerColors else {return}
        let gradient = CAGradientLayer()
        let cgColors = colors.map {$0.cgColor}
        shapeLayer.fillColor = UIColor.white.cgColor
        gradient.bounds = shapeview.bounds
        gradient.position = CGPoint(x: shapeview.bounds.midX, y: shapeview.bounds.midY)
        gradient.colors = cgColors
        gradient.mask = shapeLayer
        self.replaceLayer(shapeview, gradient)
        shape.gradientLayer = gradient
        shape.layerColors = colors
        shape.layerType = CAGradientLayer.self
    }

    private func createShapeLayers(_ shapeview: ShapeView, _ path: UIBezierPath,
                                   color: UIColor, _ isSelected: Bool) -> CAShapeLayer? {
        guard let shape = shapeview.shape else {return nil}
        let shapeLayer = CAShapeLayer()
        let frame = isSelected ? tempViewFrame() : shape.frame
        shapeLayer.frame = CGRect(origin: CGPoint(x: -frame.minX,
                                                  y: -frame.minY),
                                  size: frame.size)
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.cgColor
        shapeLayer.mask = nil
        shape.layerColors?[0] = color
        shape.shapeLayer = shapeLayer
        shape.gradientLayer = nil
        return shapeLayer
    }

    private func replaceLayer(_ shapeview: ShapeView, _ newLayer: CALayer) {
        shapeview.layer.sublayers?.removeAll()
        shapeview.layer.addSublayer(newLayer)
        changeSelectedPath(newLayer)
    }
    
    public func changePolygon(_ shapeview: ShapeView, value: UInt32, isSelected: Bool) {
        guard let path = self.regularPolygonInRect(shapeview, value, isSelected) else {return}
        self.changeShapeLayer(shapeview, path, isSelected)
    }

    private func createPathPolygon(_ shapeview: ShapeView, _ isSelected: Bool = false) {
        guard let shape = shapeview.shape else {return}
        let vUInt = UInt32(shape.polygon * 10)
        guard let path = regularPolygonInRect(shapeview, vUInt, isSelected) else {return}
        changeShapeLayer(shapeview, path, isSelected)
    }

    private func pointFrom(_ angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
    }

    private func regularPolygonInRect(_ shapeview: ShapeView, _ value: UInt32, _ isSelected: Bool) -> UIBezierPath? {
        guard let shape = shapeview.shape else {return nil}
        let frame = isSelected ? tempViewFrame() : shape.frame
        let degree = value % 12 + 3
        let center = CGPoint(x: (frame.width/2) + frame.origin.x,
                             y: (frame.height/2) + frame.origin.y)
        var angle = -CGFloat(.pi / 2.0)
        let angleIncrement = CGFloat(.pi * 2.0 / Double(degree))
        let radius = frame.width / 2.0

        let path = UIBezierPath()
        path.move(to: pointFrom(angle, radius: radius, offset: center))
        for _ in 1...degree - 1 {
            angle += angleIncrement
            path.addLine(to: pointFrom(angle, radius: radius, offset: center))
        }
        path.close()
        return path
    }
    
    private func changeSelectedPath(_ newLayer: CALayer) {
        guard let menu = self.menuShapeControl,
              let wallshapeview = menu.wallshapeview,
              let tempview = wallshapeview.tempView,
              let selectedBorder = tempview.subviews.last,
              let currLayer = selectedBorder.firstSublayer as? CAShapeLayer else {return}

        if let shapelayer = newLayer as? CAShapeLayer {
            CATransaction.removeAnimation {
                currLayer.frame = shapelayer.frame
                currLayer.path = shapelayer.path
            }
        }
        if let gradientlayer = newLayer as? CAGradientLayer,
           let shapelayer = gradientlayer.mask as? CAShapeLayer {
            CATransaction.removeAnimation {
                currLayer.frame = shapelayer.frame
                currLayer.path = shapelayer.path
            }
        }
    }
}
