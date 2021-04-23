//
//  ShapeViewControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/19/21.
//

import UIKit

class ShapeViewControl {
    private var view: UIView
    private(set) var shape: Shape?
    
    //Load shape
    init(_ view: UIView, shape: Shape) {
        self.view = view
        initLoadShapeView(shape: shape)
    }
    
    //Add shape
    init(_ view: UIView) {
        self.view = view
        initShapeView()
    }
    
    private func initLoadShapeView(shape: Shape) {
        self.shape = shape
        guard let type = shape.type else { return }
        self.createPath(by: type)
        self.createAlpha(shape.alpha)
        self.createShadow(shape.shadowRadius)
    }
    
    private func initShapeView() {
        self.shape = Shape()
        self.shape?.layerColors?.append(UIColor.random.cgColor)
        self.shape?.layerColors?.append(UIColor.random.cgColor)
        self.createPath(by: ShapeType.circle)
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
    
    private func createPathCircle() {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: view.frame.origin.x + (view.frame.size.width)/2,
                                        y: view.frame.origin.y + (view.frame.size.height)/2),
                    radius: view.frame.size.width/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
        path.close()
        changeShapeLayer(path)
    }
    
    private func createPathRectangle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: view.frame.origin.x, y: view.frame.origin.y))
        path.addLine(to: CGPoint(x: view.frame.origin.x, y: view.frame.origin.y + view.frame.size.height))
        path.addLine(to: CGPoint(x: view.frame.origin.x + view.frame.size.width, y: view.frame.origin.y + view.frame.size.height))
        path.addLine(to: CGPoint(x: view.frame.origin.x + view.frame.size.width, y: view.frame.origin.y))
        path.close()
        changeShapeLayer(path)
    }
    
    private func createPathTriangle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: view.frame.width/2 + view.frame.origin.x, y: view.frame.origin.y))
        path.addLine(to: CGPoint(x: view.frame.origin.x, y: view.frame.size.height + view.frame.origin.y))
        path.addLine(to: CGPoint(x: view.frame.size.width + view.frame.origin.x, y: view.frame.size.height + view.frame.origin.y))
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
        guard let shape = self.shape, let colors = shape.layerColors else {return}
        let gradient = CAGradientLayer()
        gradient.bounds = self.view.bounds
        gradient.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        gradient.colors = colors
        gradient.mask = shapeLayer
        self.replaceLayer(gradient)
        shape.gradientLayer = gradient
        shape.layerColors = colors
        shape.layerType = CAGradientLayer.self
    }
    
    private func createShapeLayers(_ path: UIBezierPath, color: CGColor) -> CAShapeLayer? {
        guard let shape = self.shape else {return nil}
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: CGPoint(x: -self.view.frame.minX, y: -self.view.frame.minY), size: self.view.frame.size)
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color
        shapeLayer.mask = nil
        shape.layerColors?[0] = color
        shape.shapeLayer = shapeLayer
        shape.gradientLayer = nil
        return shapeLayer
    }
    
    private func replaceLayer(_ newLayer: CALayer) {
        self.view.layer.sublayers?.removeAll()
        self.view.layer.addSublayer(newLayer)
    }
    
    public func createPlainColor() {
        guard let shape = self.shape, let shapeLayer = shape.shapeLayer else {return}
        let color = UIColor.random.cgColor
        shapeLayer.fillColor = color
        self.replaceLayer(shapeLayer)
        shape.shapeLayer = shapeLayer
        shape.layerColors?[0] = color
        shape.layerType = CAShapeLayer.self
    }
    
    public func createGradientColors() {
        guard let shape = self.shape, let shapeLayer = shape.shapeLayer else {return}
        if let gradient = shape.gradientLayer {
            let colors = [UIColor.random.cgColor, UIColor.random.cgColor]
            gradient.colors = colors
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
        self.view.layer.shadowRadius = value * 100
        self.view.layer.shadowOpacity = 0.5
        self.view.layer.shadowOffset = .zero
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
        self.shape?.shadowRadius = value
    }
    
    public func createAlpha(_ value: CGFloat) {
        self.view.alpha = value
        self.shape?.alpha = value
    }
    
    public func createPolygon(_ value: CGFloat) {
        let vUInt = UInt32(value * 10)
        let path = regularPolygonInRect(vUInt)
        changeShapeLayer(path)
        self.shape?.polygon = value
    }
    
    private func createPathPolygon() {
        guard let shape = self.shape else {return}
        let vUInt = UInt32(shape.polygon * 10)
        let path = regularPolygonInRect(vUInt)
        changeShapeLayer(path)
    }
    
    private func pointFrom(_ angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
    }

    private func regularPolygonInRect(_ value: UInt32) -> UIBezierPath {
        let degree = value % 12 + 3
        let center = CGPoint(x: (view.frame.width/2) + view.frame.origin.x, y: (view.frame.height/2) + view.frame.origin.y)
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
    
    public func changeSliderValue(_ slider: SliderMenu) {
        switch slider.type {
            case .shadow:
                slider.setValue(Float(shape?.shadowRadius ?? 0), animated: true)
            case .alpha:
                slider.setValue(Float(shape?.alpha ?? 1), animated: true)
            case .polygon:
                slider.setValue(Float(shape?.polygon ?? 0), animated: true)
            default:
                break
        }
    }
}
