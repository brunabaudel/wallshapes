//
//  ShapeView.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

protocol ShapeViewDelegate {
    func deleteView(_ shapeView: ShapeView)
}

class ShapeView: UIView {
    var delegate: ShapeViewDelegate?
    var shape: Shape?
    var menuShapeView: MenuShapeView?
    
    init(frame: CGRect, menu: MenuShapeView) {
        super.init(frame: frame)
        menuShapeView = menu
        menuShapeView?.delegate = self
        
        backgroundColor = .clear
        
        initShapeView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initShapeView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initShapeView()
    }
}

extension ShapeView {
    func initShapeView() {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: frame.origin.x + (frame.size.width)/2,
                                        y: frame.origin.y + (frame.size.height)/2),
                    radius: frame.size.width/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.random().cgColor
        shapeLayer.frame = CGRect(origin: CGPoint(x: -self.frame.minX, y: -self.frame.minY), size: self.frame.size)
        self.layer.addSublayer(shapeLayer)
        
        self.shape = Shape()
        self.shape?.path = path.cgPath
        self.shape?.shapeLayerColor = shapeLayer.fillColor
        self.shape?.type = ShapeType.circle
        self.shape?.shapeLayer = shapeLayer
        self.shape?.gradientLayerColors = [UIColor.random().cgColor, UIColor.random().cgColor]
        
        self.createShadow(0)
        self.createAlpha(1)
    }
    
    func createPathCircle() {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: frame.origin.x + (frame.size.width)/2,
                                        y: frame.origin.y + (frame.size.height)/2),
                    radius: frame.size.width/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
        path.close()
        changeShapeLayer(path, type: ShapeType.circle)
    }
    
    func createPathRectangle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.origin.x, y: frame.origin.y))
        path.addLine(to: CGPoint(x: frame.origin.x, y: frame.origin.y + frame.size.height))
        path.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y + frame.size.height))
        path.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y))
        path.close()
        changeShapeLayer(path, type: ShapeType.rectangle)
    }
    
    func createPathTriangle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width/2 + frame.origin.x, y: frame.origin.y))
        path.addLine(to: CGPoint(x: frame.origin.x, y: frame.size.height + frame.origin.y))
        path.addLine(to: CGPoint(x: frame.size.width + frame.origin.x, y: frame.size.height + frame.origin.y))
        path.close()
        changeShapeLayer(path, type: ShapeType.triangle)
    }
    
    func changeShapeLayer(_ path: UIBezierPath, type: ShapeType) {
        guard let currLayer = self.firstSublayer() else {return}
        guard let shape = self.shape, let color = shape.shapeLayerColor else {return}
        guard let shapeLayer = createShapeLayers(path, type: type, color: color) else {return}
        
        if currLayer.typeOfLayer().isEqual(CAShapeLayer.self) {
            replaceShapeLayer(shapeLayer)
        }
        
        if currLayer.typeOfLayer().isEqual(CAGradientLayer.self) {
            replaceGradientLayer(shapeLayer)
        }
    }
    
    func replaceShapeLayer(_ shapeLayer: CAShapeLayer) {
        replaceLayer(shapeLayer)
    }
    
    func replaceGradientLayer(_ shapeLayer: CAShapeLayer) {
        guard let shape = self.shape, let colors = shape.gradientLayerColors else {return}
        let gradient = CAGradientLayer()
        gradient.bounds = self.bounds
        gradient.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        gradient.colors = colors
        gradient.mask = shapeLayer
        self.replaceLayer(gradient)
        shape.gradientLayer = gradient
        shape.gradientLayerColors = colors
    }
    
    func createShapeLayers(_ path: UIBezierPath, type: ShapeType, color: CGColor) -> CAShapeLayer? {
        guard let shape = self.shape else {return nil}
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: CGPoint(x: -self.frame.minX, y: -self.frame.minY), size: self.frame.size)
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color
        shapeLayer.mask = nil
        shape.type = type
        shape.shapeLayerColor = color
        shape.shapeLayer = shapeLayer
        shape.gradientLayer = nil
        return shapeLayer
    }
    
    func replaceLayer(_ newLayer: CALayer) {
        self.layer.sublayers?.removeAll()
        self.layer.addSublayer(newLayer)
    }
    
    func createPlainColor() {
        guard let shape = self.shape, let shapeLayer = shape.shapeLayer else {return}
        let color = UIColor.random().cgColor
        shapeLayer.fillColor = color
        self.replaceLayer(shapeLayer)
        shape.shapeLayer = shapeLayer
        shape.shapeLayerColor = color
    }
    
    func createGradientColors() {
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
    
    func createShadow(_ value: CGFloat) {
        self.layer.shadowRadius = value * 100
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.shape?.shadowRadius = value
    }
    
    func createAlpha(_ value: CGFloat) {
        self.alpha = value
        self.shape?.alpha = value
    }
}

extension ShapeView {
    func selectShape() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}

extension ShapeView: MenuShapeViewDelegate {
    func willApplyPlainColorShape(_ sender: UIButton) {
        createPlainColor()
    }
    
    func willDeleteShape(_ sender: UIButton) {
        delegate?.deleteView(self)
    }
    
    func willChangeShape(_ sender: UIButton, type: ShapeType) {
        switch type {
            case ShapeType.circle:
                createPathCircle()
            case ShapeType.rectangle:
                createPathRectangle()
            case ShapeType.triangle:
                createPathTriangle()
        }
    }
    
    func willApplyGradientShape(_ sender: UIButton) {
        createGradientColors()
    }
    
    func willApplyShadowShape(_ sender: SliderMenu) {
        let value = CGFloat(sender.value)
        createShadow(value)
    }
    
    func willApplyAlphaShape(_ sender: SliderMenu) {
        let value = CGFloat(sender.value)
        createAlpha(value)
    }
    
    func onSliderValue(_ slider: SliderMenu) {
        guard let shape = self.shape,
              let shadowRadius = shape.shadowRadius,
              let alpha = shape.alpha
        else {return}
        
        switch slider.type {
            case .shadow:
                slider.setValue(Float(shadowRadius), animated: true)
            case .alpha:
                slider.setValue(Float(alpha), animated: true)
            default:
                break
        }
    }
    
    func showMenuShape() {
        self.menuShapeView?.delegate = self
        self.menuShapeView?.showMenu()
    }
}
