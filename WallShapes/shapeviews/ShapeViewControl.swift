//
//  ShapeViewControl.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/19/21.
//

import UIKit

class ShapeViewControl {
    private var view: UIView
    private var shape: Shape?
    
    init(_ view: UIView) {
        self.view = view
        initShapeView()
    }
    
    private func initShapeView() {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: view.frame.origin.x + (view.frame.size.width)/2,
                                        y: view.frame.origin.y + (view.frame.size.height)/2),
                    radius: view.frame.size.width/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.random().cgColor
        shapeLayer.frame = CGRect(origin: CGPoint(x: -self.view.frame.minX, y: -self.view.frame.minY), size: self.view.frame.size)
        self.view.layer.addSublayer(shapeLayer)
        
        self.shape = Shape()
        self.shape?.path = path.cgPath
        self.shape?.shapeLayerColor = shapeLayer.fillColor
        self.shape?.type = ShapeType.circle
        self.shape?.shapeLayer = shapeLayer
        self.shape?.gradientLayerColors = [UIColor.random().cgColor, UIColor.random().cgColor]
        
        self.createShadow(0)
        self.createAlpha(1)
    }
    
    public func createPathCircle() {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: view.frame.origin.x + (view.frame.size.width)/2,
                                        y: view.frame.origin.y + (view.frame.size.height)/2),
                    radius: view.frame.size.width/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
        path.close()
        changeShapeLayer(path, type: ShapeType.circle)
    }
    
    public func createPathRectangle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: view.frame.origin.x, y: view.frame.origin.y))
        path.addLine(to: CGPoint(x: view.frame.origin.x, y: view.frame.origin.y + view.frame.size.height))
        path.addLine(to: CGPoint(x: view.frame.origin.x + view.frame.size.width, y: view.frame.origin.y + view.frame.size.height))
        path.addLine(to: CGPoint(x: view.frame.origin.x + view.frame.size.width, y: view.frame.origin.y))
        path.close()
        changeShapeLayer(path, type: ShapeType.rectangle)
    }
    
    public func createPathTriangle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: view.frame.width/2 + view.frame.origin.x, y: view.frame.origin.y))
        path.addLine(to: CGPoint(x: view.frame.origin.x, y: view.frame.size.height + view.frame.origin.y))
        path.addLine(to: CGPoint(x: view.frame.size.width + view.frame.origin.x, y: view.frame.size.height + view.frame.origin.y))
        path.close()
        changeShapeLayer(path, type: ShapeType.triangle)
    }
    
    private func changeShapeLayer(_ path: UIBezierPath, type: ShapeType) {
        guard let currLayer = self.view.firstSublayer() else {return}
        guard let shape = self.shape, let color = shape.shapeLayerColor else {return}
        guard let shapeLayer = createShapeLayers(path, type: type, color: color) else {return}
        
        if currLayer.typeOfLayer().isEqual(CAShapeLayer.self) {
            replaceShapeLayer(shapeLayer)
        }
        
        if currLayer.typeOfLayer().isEqual(CAGradientLayer.self) {
            replaceGradientLayer(shapeLayer)
        }
    }
    
    private func replaceShapeLayer(_ shapeLayer: CAShapeLayer) {
        replaceLayer(shapeLayer)
    }
    
    private func replaceGradientLayer(_ shapeLayer: CAShapeLayer) {
        guard let shape = self.shape, let colors = shape.gradientLayerColors else {return}
        let gradient = CAGradientLayer()
        gradient.bounds = self.view.bounds
        gradient.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        gradient.colors = colors
        gradient.mask = shapeLayer
        self.replaceLayer(gradient)
        shape.gradientLayer = gradient
        shape.gradientLayerColors = colors
    }
    
    private func createShapeLayers(_ path: UIBezierPath, type: ShapeType, color: CGColor) -> CAShapeLayer? {
        guard let shape = self.shape else {return nil}
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: CGPoint(x: -self.view.frame.minX, y: -self.view.frame.minY), size: self.view.frame.size)
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color
        shapeLayer.mask = nil
        shape.type = type
        shape.shapeLayerColor = color
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
        let color = UIColor.random().cgColor
        shapeLayer.fillColor = color
        self.replaceLayer(shapeLayer)
        shape.shapeLayer = shapeLayer
        shape.shapeLayerColor = color
    }
    
    public func createGradientColors() {
        guard let shape = self.shape, let shapeLayer = shape.shapeLayer else {return}
        if let gradient = shape.gradientLayer {
            let colors = [UIColor.random().cgColor, UIColor.random().cgColor]
            gradient.colors = colors
            gradient.mask = shapeLayer
            self.replaceLayer(gradient)
            shape.gradientLayer = gradient
            shape.gradientLayerColors = colors
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
    
    public func alpha() -> CGFloat {
        guard let shape = self.shape, let alpha = shape.alpha else {return 0}
        return alpha
    }
    
    public func shadow() -> CGFloat {
        guard let shape = self.shape, let shadowRadius = shape.shadowRadius else {return 0}
        return shadowRadius
    }
}
