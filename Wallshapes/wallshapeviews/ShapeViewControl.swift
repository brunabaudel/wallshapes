//
//  ShapeViewControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/19/21.
//

import UIKit

final class ShapeViewControl {
    private var view: ShapeView?
    private(set) var shape: Shape?

    // Load shape
    init(_ view: ShapeView, shape: Shape) {
        self.view = view
        initLoadShapeView(shape: shape)
    }

    // Add shape
    init(_ view: ShapeView) {
        self.view = view
        initShapeView()
    }

    public func createPath(by type: ShapeType) {
        self.shape?.type = type
        switch type {
        case ShapeType.circle:
            self.createPathCircle()
        case ShapeType.rectangle:
            self.createPathRectangle()
        case ShapeType.triangle:
            self.createPathTriangle()
        case ShapeType.polygon:
            self.createPathPolygon()
        }
    }

    public func createPlainColor() {
        guard let shape = self.shape, let shapeLayer = shape.shapeLayer else {return}
        let color = UIColor.random
        CATransaction.removeAnimation {
            shapeLayer.fillColor = color.withAlphaComponent(shape.alpha).cgColor
            self.replaceLayer(shapeLayer)
        }
        shape.shapeLayer = shapeLayer
        shape.layerColors?[0] = color
        shape.gradientLayer = nil
        shape.layerType = CAShapeLayer.self
    }

    public func createGradientColors() {
        guard let shape = self.shape, let shapeLayer = shape.shapeLayer else {return}
        if let gradient = shape.gradientLayer {
            let colors = [UIColor.random, UIColor.random]
            let cgColors = colors.map {$0.withAlphaComponent(shape.alpha).cgColor}
            gradient.colors = cgColors
            gradient.mask = shapeLayer
            self.replaceLayer(gradient)
            shape.gradientLayer = gradient
            shape.layerColors = colors
            shape.layerType = CAGradientLayer.self
            return
        }
        replaceGradientLayer(shapeLayer)
    }

    public func createShadow(_ value: CGFloat) {
        guard let view = self.view else {return}
        view.layer.shadowRadius = value * 100
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        if value == 0 { view.layer.shadowColor = UIColor.clear.cgColor }
        self.shape?.shadowRadius = value
    }

    public func createAlpha(_ value: CGFloat) {
        guard let view = self.view, let sublayers = view.layer.sublayers else {return}
        if let shapelayer = sublayers.first as? CAShapeLayer,
           let cgcolor = shapelayer.fillColor {
            let color = UIColor(cgColor: cgcolor)
            self.shape?.alpha = value
            CATransaction.removeAnimation {
                shapelayer.fillColor = color.withAlphaComponent(value).cgColor
            }
            return
        }
        
        if let gradietlayer = sublayers.first as? CAGradientLayer,
           let cgcolors = gradietlayer.colors as? [CGColor] {
            let colors = cgcolors.map {UIColor(cgColor: $0).withAlphaComponent(value).cgColor}
            self.shape?.alpha = value
            CATransaction.removeAnimation {
                gradietlayer.colors = colors
            }
            return
        }
    }

    public func createPolygon(_ value: CGFloat) {
        let vUInt = UInt32(value * 10)
        guard let path = regularPolygonInRect(vUInt) else {return}
        changeShapeLayer(path)
        self.shape?.polygon = value
    }

    public func clone(_ menuShapeView: MenuShapeControl?) -> ShapeView? {
        guard let view = self.view, let menuShapeView = menuShapeView, let shape = self.shape else { return nil }
        let frame = view.frame
        let clonedShape = Shape()
        clonedShape.alpha = shape.alpha
        clonedShape.layerColors = shape.layerColors
        clonedShape.layerType = shape.layerType
        clonedShape.polygon = shape.polygon
        clonedShape.shadowRadius = shape.shadowRadius
        clonedShape.frame = shape.frame
        clonedShape.type = shape.type
        return ShapeView(frame: frame, menu: menuShapeView, shape: clonedShape)
    }
}

// MARK: - Class methods

extension ShapeViewControl {
    private func initLoadShapeView(shape: Shape) {
        self.shape = shape
        guard let type = shape.type else { return }
        self.createPath(by: type)
        self.createAlpha(shape.alpha)
        self.createShadow(shape.shadowRadius)
    }

    private func initShapeView() {
        self.shape = Shape()
        self.shape?.layerColors?.append(UIColor.random)
        self.shape?.layerColors?.append(UIColor.random)
        self.createPath(by: ShapeType.circle)
    }

    private func createPathCircle() {
        guard let view = self.view else {return}
        self.shape?.polygon = 0
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: view.frame.origin.x + (view.frame.size.width)/2,
                                        y: view.frame.origin.y + (view.frame.size.height)/2),
                    radius: view.frame.size.width/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
        path.close()
        changeShapeLayer(path)
    }

    private func createPathRectangle() {
        guard let view = self.view else {return}
        self.shape?.polygon = 0
        let path = UIBezierPath()
        path.move(to: CGPoint(x: view.frame.origin.x, y: view.frame.origin.y))
        path.addLine(to: CGPoint(x: view.frame.origin.x, y: view.frame.origin.y + view.frame.size.height))
        path.addLine(to: CGPoint(x: view.frame.origin.x + view.frame.size.width,
                                 y: view.frame.origin.y + view.frame.size.height))
        path.addLine(to: CGPoint(x: view.frame.origin.x + view.frame.size.width, y: view.frame.origin.y))
        path.close()
        changeShapeLayer(path)
    }

    private func createPathTriangle() {
        guard let view = self.view else {return}
        self.shape?.polygon = 0
        let path = UIBezierPath()
        path.move(to: CGPoint(x: view.frame.width/2 + view.frame.origin.x, y: view.frame.origin.y))
        path.addLine(to: CGPoint(x: view.frame.origin.x, y: view.frame.size.height + view.frame.origin.y))
        path.addLine(to: CGPoint(x: view.frame.size.width + view.frame.origin.x,
                                 y: view.frame.size.height + view.frame.origin.y))
        path.close()
        changeShapeLayer(path)
    }

    private func changeShapeLayer(_ path: UIBezierPath) {
        guard let shape = self.shape, let color = shape.layerColors?.first else {return}
        guard let shapeLayer = createShapeLayers(path, color: color) else {return}
        if shape.layerType.isEqual(CAShapeLayer.self) {
            replaceShapeLayer(shapeLayer)
        }
        if shape.layerType.isEqual(CAGradientLayer.self) {
            replaceGradientLayer(shapeLayer)
        }
    }

    private func replaceShapeLayer(_ shapeLayer: CAShapeLayer) {
        self.replaceLayer(shapeLayer)
    }

    private func replaceGradientLayer(_ shapeLayer: CAShapeLayer) {
        guard let view = self.view, let shape = self.shape, let colors = shape.layerColors else {return}
        let gradient = CAGradientLayer()
        let cgColors = colors.map {$0.withAlphaComponent(shape.alpha).cgColor}
        shapeLayer.fillColor = UIColor.white.withAlphaComponent(1.0).cgColor
        gradient.bounds = view.bounds
        gradient.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        gradient.colors = cgColors
        gradient.mask = shapeLayer
        self.replaceLayer(gradient)
        shape.gradientLayer = gradient
        shape.layerColors = colors
        shape.layerType = CAGradientLayer.self
    }

    private func createShapeLayers(_ path: UIBezierPath, color: UIColor) -> CAShapeLayer? {
        guard let view = self.view, let shape = self.shape else {return nil}
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: CGPoint(x: -view.frame.minX,
                                                  y: -view.frame.minY),
                                  size: view.frame.size)
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.withAlphaComponent(shape.alpha).cgColor
        shapeLayer.mask = nil
        shape.layerColors?[0] = color
        shape.shapeLayer = shapeLayer
        shape.gradientLayer = nil
        return shapeLayer
    }

    private func replaceLayer(_ newLayer: CALayer) {
        guard let view = self.view else {return}
        view.layer.sublayers?.removeAll()
        view.layer.addSublayer(newLayer)
    }

    private func createPathPolygon() {
        guard let shape = self.shape else {return}
        let vUInt = UInt32(shape.polygon * 10)
        guard let path = regularPolygonInRect(vUInt) else {return}
        changeShapeLayer(path)
    }

    private func pointFrom(_ angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
    }

    private func regularPolygonInRect(_ value: UInt32) -> UIBezierPath? {
        guard let view = self.view else {return nil}
        let degree = value % 12 + 3
        let center = CGPoint(x: (view.frame.width/2) + view.frame.origin.x,
                             y: (view.frame.height/2) + view.frame.origin.y)
        var angle = -CGFloat(.pi / 2.0)
        let angleIncrement = CGFloat(.pi * 2.0 / Double(degree))
        let radius = view.frame.width / 2.0

        let path = UIBezierPath()
        path.move(to: pointFrom(angle, radius: radius, offset: center))
        for _ in 1...degree - 1 {
            angle += angleIncrement
            path.addLine(to: pointFrom(angle, radius: radius, offset: center))
        }
        path.close()
        return path
    }
}
