//
//  ShapeViewControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/19/21.
//

import UIKit

final class ShapeViewControl {
    private weak var menuShapeControl: MenuShapeControl?
    
    init(_ menuShapeControl: MenuShapeControl) {
        self.menuShapeControl = menuShapeControl
        self.menuShapeControl?.delegate = self
    }
    
    public func createShapeView(_ shapeview: ShapeView) {
        guard let shape = shapeview.shape, let type = shape.type else {
            shapeview.shape?.layerColors?.append(UIColor.random)
            shapeview.shape?.layerColors?.append(UIColor.random)
            self.createPath(shapeview, by: ShapeType.circle)
            return
        }
        self.createPath(shapeview, by: type)
        self.createAlpha(shapeview, shape.alpha)
        self.createShadow(shapeview, shape.shadowRadius)
    }
    
    private func createPath(_ shapeview: ShapeView?, by type: ShapeType) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        shape.type = type
        switch type {
        case ShapeType.circle:
            self.createPathCircle(shapeview)
        case ShapeType.rectangle:
            self.createPathRectangle(shapeview)
        case ShapeType.triangle:
            self.createPathTriangle(shapeview)
        case ShapeType.polygon:
            self.createPathPolygon(shapeview)
        }
    }

    private func createPlainColor(_ shapeview: ShapeView?) {
        guard let shapeview = shapeview, let shape = shapeview.shape, let shapeLayer = shape.shapeLayer else {return}
        let color = UIColor.random
        CATransaction.removeAnimation {
            shapeLayer.fillColor = color.withAlphaComponent(shape.alpha).cgColor
            self.replaceLayer(shapeview, shapeLayer)
        }
        shape.shapeLayer = shapeLayer
        shape.layerColors?[0] = color
        shape.gradientLayer = nil
        shape.layerType = CAShapeLayer.self
    }

    private func createGradientColors(_ shapeview: ShapeView?) {
        guard let shapeview = shapeview, let shape = shapeview.shape, let shapeLayer = shape.shapeLayer else {return}
        if let gradient = shape.gradientLayer {
            let colors = [UIColor.random, UIColor.random]
            let cgColors = colors.map {$0.withAlphaComponent(shape.alpha).cgColor}
            gradient.colors = cgColors
            gradient.mask = shapeLayer
            self.replaceLayer(shapeview, gradient)
            shape.gradientLayer = gradient
            shape.layerColors = colors
            shape.layerType = CAGradientLayer.self
            return
        }
        replaceGradientLayer(shapeview, shapeLayer)
    }

    private func createShadow(_ shapeview: ShapeView?, _ value: CGFloat) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        shapeview.layer.shadowRadius = value * 100
        shapeview.layer.shadowOpacity = 0.5
        shapeview.layer.shadowOffset = .zero
        shapeview.layer.shadowColor = UIColor.black.cgColor
        shapeview.layer.shouldRasterize = true
        shapeview.layer.rasterizationScale = UIScreen.main.scale
        if value == 0 { shapeview.layer.shadowColor = UIColor.clear.cgColor }
        shape.shadowRadius = value
    }

    private func createAlpha(_ shapeview: ShapeView?, _ value: CGFloat) {
        guard let shapeview = shapeview, let shape = shapeview.shape, let sublayers = shapeview.layer.sublayers else {return}
        if let shapelayer = sublayers.first as? CAShapeLayer,
           let cgcolor = shapelayer.fillColor {
            let color = UIColor(cgColor: cgcolor)
            shape.alpha = value
            CATransaction.removeAnimation {
                shapelayer.fillColor = color.withAlphaComponent(value).cgColor
            }
            return
        }
        
        if let gradietlayer = sublayers.first as? CAGradientLayer,
           let cgcolors = gradietlayer.colors as? [CGColor] {
            let colors = cgcolors.map {UIColor(cgColor: $0).withAlphaComponent(value).cgColor}
            shape.alpha = value
            CATransaction.removeAnimation {
                gradietlayer.colors = colors
            }
            return
        }
    }

    private func createPolygon(_ shapeview: ShapeView?, _ value: CGFloat) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        let vUInt = UInt32(value * 10)
        guard let path = regularPolygonInRect(shapeview, vUInt) else {return}
        changeShapeLayer(shapeview, path)
        shape.polygon = value
    }

    private func clone(_ shapeview: ShapeView?) -> ShapeView? {
        guard let shapeview = shapeview, let shape = shapeview.shape else { return nil }
        let clonedShape = Shape()
        clonedShape.alpha = shape.alpha
        clonedShape.layerColors = shape.layerColors
        clonedShape.layerType = shape.layerType
        clonedShape.polygon = shape.polygon
        clonedShape.shadowRadius = shape.shadowRadius
        clonedShape.frame = shape.frame
        clonedShape.type = shape.type
        let clonedShapeView = ShapeView(frame: shapeview.frame, shape: clonedShape)
        self.createShapeView(clonedShapeView)
        return clonedShapeView
    }
}

// MARK: - Class methods

extension ShapeViewControl {
    private func createPathCircle(_ shapeview: ShapeView?) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        shape.polygon = 0
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: shapeview.frame.origin.x + (shapeview.frame.size.width)/2,
                                        y: shapeview.frame.origin.y + (shapeview.frame.size.height)/2),
                    radius: shapeview.frame.size.width/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
        path.close()
        changeShapeLayer(shapeview, path)
    }

    private func createPathRectangle(_ shapeview: ShapeView?) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        shape.polygon = 0
        let path = UIBezierPath()
        path.move(to: CGPoint(x: shapeview.frame.origin.x, y: shapeview.frame.origin.y))
        path.addLine(to: CGPoint(x: shapeview.frame.origin.x, y: shapeview.frame.origin.y + shapeview.frame.size.height))
        path.addLine(to: CGPoint(x: shapeview.frame.origin.x + shapeview.frame.size.width,
                                 y: shapeview.frame.origin.y + shapeview.frame.size.height))
        path.addLine(to: CGPoint(x: shapeview.frame.origin.x + shapeview.frame.size.width, y: shapeview.frame.origin.y))
        path.close()
        changeShapeLayer(shapeview, path)
    }

    private func createPathTriangle(_ shapeview: ShapeView?) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        shape.polygon = 0
        let path = UIBezierPath()
        path.move(to: CGPoint(x: shapeview.frame.width/2 + shapeview.frame.origin.x, y: shapeview.frame.origin.y))
        path.addLine(to: CGPoint(x: shapeview.frame.origin.x, y: shapeview.frame.size.height + shapeview.frame.origin.y))
        path.addLine(to: CGPoint(x: shapeview.frame.size.width + shapeview.frame.origin.x,
                                 y: shapeview.frame.size.height + shapeview.frame.origin.y))
        path.close()
        changeShapeLayer(shapeview, path)
    }

    private func changeShapeLayer(_ shapeview: ShapeView?, _ path: UIBezierPath) {
        guard let shapeview = shapeview, let shape = shapeview.shape, let color = shape.layerColors?.first else {return}
        guard let shapeLayer = createShapeLayers(shapeview, path, color: color) else {return}
        if shape.layerType.isEqual(CAShapeLayer.self) {
            replaceShapeLayer(shapeview, shapeLayer)
        }
        if shape.layerType.isEqual(CAGradientLayer.self) {
            replaceGradientLayer(shapeview, shapeLayer)
        }
    }

    private func replaceShapeLayer(_ shapeview: ShapeView?, _ shapeLayer: CAShapeLayer) {
        self.replaceLayer(shapeview, shapeLayer)
    }

    private func replaceGradientLayer(_ shapeview: ShapeView?, _ shapeLayer: CAShapeLayer) {
        guard let shapeview = shapeview, let shape = shapeview.shape, let colors = shape.layerColors else {return}
        let gradient = CAGradientLayer()
        let cgColors = colors.map {$0.withAlphaComponent(shape.alpha).cgColor}
        shapeLayer.fillColor = UIColor.white.withAlphaComponent(1.0).cgColor
        gradient.bounds = shapeview.bounds
        gradient.position = CGPoint(x: shapeview.bounds.midX, y: shapeview.bounds.midY)
        gradient.colors = cgColors
        gradient.mask = shapeLayer
        self.replaceLayer(shapeview, gradient)
        shape.gradientLayer = gradient
        shape.layerColors = colors
        shape.layerType = CAGradientLayer.self
    }

    private func createShapeLayers(_ shapeview: ShapeView?, _ path: UIBezierPath, color: UIColor) -> CAShapeLayer? {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return nil}
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: CGPoint(x: -shapeview.frame.minX,
                                                  y: -shapeview.frame.minY),
                                  size: shapeview.frame.size)
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.withAlphaComponent(shape.alpha).cgColor
//        shapeLayer.lineDashPattern = [3, 3]
//        shapeLayer.lineWidth = 5
//        shapeLayer.strokeColor = UIColor.yellow.cgColor
        shapeLayer.mask = nil
        shape.layerColors?[0] = color
        shape.shapeLayer = shapeLayer
        shape.gradientLayer = nil
        return shapeLayer
    }

    private func replaceLayer(_ shapeview: ShapeView?, _ newLayer: CALayer) {
        guard let shapeview = shapeview else {return}
        shapeview.layer.sublayers?.removeAll()
        shapeview.layer.addSublayer(newLayer)
    }

    private func createPathPolygon(_ shapeview: ShapeView?) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        let vUInt = UInt32(shape.polygon * 10)
        guard let path = regularPolygonInRect(shapeview, vUInt) else {return}
        changeShapeLayer(shapeview, path)
    }

    private func pointFrom(_ angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
    }

    private func regularPolygonInRect(_ shapeview: ShapeView?, _ value: UInt32) -> UIBezierPath? {
        guard let shapeview = shapeview else {return nil}
        let degree = value % 12 + 3
        let center = CGPoint(x: (shapeview.frame.width/2) + shapeview.frame.origin.x,
                             y: (shapeview.frame.height/2) + shapeview.frame.origin.y)
        var angle = -CGFloat(.pi / 2.0)
        let angleIncrement = CGFloat(.pi * 2.0 / Double(degree))
        let radius = shapeview.frame.width / 2.0

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

extension ShapeViewControl: MenuShapeControlDelegate {
    func onSliderMenu(_ sender: SliderMenu, shapeView: ShapeView) {
        guard let shape = shapeView.shape else {return}
        switch sender.type {
        case .shadow:
            let value = CGFloat(sender.value)
            self.createShadow(shapeView, value)
            shape.shadowRadius = value
        case .alpha:
            let value = CGFloat(sender.value)
            self.createAlpha(shapeView, value)
            shape.alpha = value
        case .polygon:
            let value = CGFloat(sender.value)
            self.createPolygon(shapeView, value)
            shape.polygon = value
            shape.type = .polygon
        default:
            break
        }
    }
    
    func onMainMenu(_ sender: TypeButton<MainMenuView>, shapeView: ShapeView) {
        guard let type = sender.type, let menuShapeControl = self.menuShapeControl else {return}
        switch type {
        case .clone:
            self.cloneShapeView(shapeView)
        case .gradient:
           menuShapeControl.hideSlider()
           menuShapeControl.hideShapeMenu()
           menuShapeControl.hideMenuArrange()
            self.createGradientColors(shapeView)
        case .plainColor:
           menuShapeControl.hideSlider()
           menuShapeControl.hideShapeMenu()
           menuShapeControl.hideMenuArrange()
           self.createPlainColor(shapeView)
        case .shadow, .transparency:
            self.selectSlider(shapeView, type, isSelected: sender.isSelected)
        case .arrangeSet:
           menuShapeControl.hideShapeMenu()
           menuShapeControl.hideSlider()
           menuShapeControl.showArrangeMenu()
        case .shapes:
           menuShapeControl.hideMenuArrange()
           menuShapeControl.hideSlider()
           menuShapeControl.showShapeMenu()
        }
    }
    
    func onArrangeMenu(_ sender: TypeButton<ArrangeMenuView>, shapeView: ShapeView) {
        guard let type = sender.type,
              let menuShapeControl = self.menuShapeControl,
              let wallshapeview = menuShapeControl.wallshapeview else {return}
        switch type {
        case .bringToFront:
            wallshapeview.insertSubview(shapeView, at: wallshapeview.subviews.count - 1)
        case .bringForward:
            guard let index = wallshapeview.subviews.firstIndex(of: shapeView) else { return }
            if index < wallshapeview.subviews.count {
                wallshapeview.insertSubview(shapeView, at: index + 1)
            }
        case .sendToBack:
            wallshapeview.insertSubview(shapeView, at: 1)
        case .sendBackward:
            guard let index = wallshapeview.subviews.firstIndex(of: shapeView) else { return }
            if index > 1 {
                wallshapeview.insertSubview(shapeView, at: index - 1)
            }
        }
    }
    
    func onShapeMenu(_ sender: TypeButton<ShapeMenuView>, shapeView: ShapeView) {
        guard let type = sender.type else {return}
        switch type {
        case .circle:
            self.createPath(shapeView, by: .circle)
        case .square:
            self.createPath(shapeView, by: .rectangle)
        case .triangle:
            self.createPath(shapeView, by: .triangle)
        case .polygon:
            guard let menuShapeControl = self.menuShapeControl,
                  let shape = shapeView.shape else {return}
            menuShapeControl.selectSlider(.polygon, value: Float(shape.polygon), sender.isSelected)
        }
    }
    
    private func cloneShapeView(_ shapeView: ShapeView) {
        guard let menuShapeControl = self.menuShapeControl,
              let wallshapeview = menuShapeControl.wallshapeview else {return}
        menuShapeControl.hideSlider()
        menuShapeControl.hideMenuArrange()
        menuShapeControl.hideShapeMenu()
        guard let clonedShapeView = self.clone(shapeView) else {return}
        wallshapeview.addSubview(clonedShapeView)
    }
    
    private func selectSlider(_ shapeView: ShapeView, _ type: MainMenuTypeEnum, isSelected: Bool) {
        guard let menuShapeControl = self.menuShapeControl else {return}
        menuShapeControl.hideMenuArrange()
        menuShapeControl.hideShapeMenu()
        switch type {
        case .shadow:
            guard let value = shapeView.shape?.shadowRadius else {return}
            menuShapeControl.selectSlider(.shadow, value: Float(value), isSelected)
        case .transparency:
            guard let value = shapeView.shape?.alpha else {return}
            menuShapeControl.selectSlider(.alpha, value: Float(value), isSelected)
        default:
            NSLog("Error")
        }
    }
    
    public func setupSliderMenuShape(_ shapeView: ShapeView) {
        guard let menuShapeControl = self.menuShapeControl, let type = menuShapeControl.typeSlider() else {return}
        switch type {
        case .shadow:
            menuShapeControl.setupSlider(value: Float(shapeView.shape?.shadowRadius ?? 0))
        case .alpha:
            menuShapeControl.setupSlider(value: Float(shapeView.shape?.alpha ?? 1))
        case .polygon:
            menuShapeControl.setupSlider(value: Float(shapeView.shape?.polygon ?? 0))
        }
    }
}
