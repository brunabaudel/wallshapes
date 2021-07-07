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

    private func createPath(_ shapeview: ShapeView?, by type: ShapeType, _ isSelected: Bool = false) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
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

    private func createPlainColor(_ shapeview: ShapeView?) {
        guard let shapeview = shapeview, let shape = shapeview.shape, let shapeLayer = shape.shapeLayer else {return}
        let color = UIColor.random
        CATransaction.removeAnimation {
            shapeLayer.fillColor = color.cgColor
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
            let cgColors = colors.map {$0.cgColor}
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
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        shape.alpha = value
        shapeview.alpha = value
    }

    private func createPolygon(_ shapeview: ShapeView?, _ value: CGFloat, _ isSelected: Bool = false) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        let vUInt = UInt32(value * 10)
        guard let path = regularPolygonInRect(shapeview, vUInt, isSelected) else {return}
        changeShapeLayer(shapeview, path, isSelected)
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
        let clonedShapeView = ShapeView(frame: shape.frame, shape: clonedShape)
        self.createShapeView(clonedShapeView)
        return clonedShapeView
    }
}

// MARK: - Class methods

extension ShapeViewControl {
    private func tempViewFrame() -> CGRect {
        guard let menuShapeControl = self.menuShapeControl,
              let view = menuShapeControl.wallshapeview, let tempview = view.tempView else {return CGRect.zero}
        return tempview.frame
    }

    private func createPathCircle(_ shapeview: ShapeView?, _ isSelected: Bool = false) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        shape.polygon = 0
        let frame = isSelected ? tempViewFrame() : shapeview.frame
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: frame.origin.x + (frame.size.width)/2,
                                        y: frame.origin.y + (frame.size.height)/2),
                    radius: frame.size.width/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
        path.close()
        changeShapeLayer(shapeview, path, isSelected)
    }

    private func createPathRectangle(_ shapeview: ShapeView?, _ isSelected: Bool = false) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        shape.polygon = 0
        let frame = isSelected ? tempViewFrame() : shapeview.frame
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.origin.x, y: frame.origin.y))
        path.addLine(to: CGPoint(x: frame.origin.x, y: frame.origin.y + frame.size.height))
        path.addLine(to: CGPoint(x: frame.origin.x + frame.size.width,
                                 y: frame.origin.y + frame.size.height))
        path.addLine(to: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y))
        path.close()
        changeShapeLayer(shapeview, path, isSelected)
    }

    private func createPathTriangle(_ shapeview: ShapeView?, _ isSelected: Bool = false) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        shape.polygon = 0
        let frame = isSelected ? tempViewFrame() : shapeview.frame
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width/2 + frame.origin.x, y: frame.origin.y))
        path.addLine(to: CGPoint(x: frame.origin.x, y: frame.size.height + frame.origin.y))
        path.addLine(to: CGPoint(x: frame.size.width + frame.origin.x,
                                 y: frame.size.height + frame.origin.y))
        path.close()
        changeShapeLayer(shapeview, path, isSelected)
    }

    private func changeShapeLayer(_ shapeview: ShapeView?, _ path: UIBezierPath, _ isSelected: Bool) {
        guard let shapeview = shapeview,
              let shape = shapeview.shape,
              let color = shape.layerColors?.first,
              let shapeLayer = createShapeLayers(shapeview, path, color: color, isSelected) else {return}
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

    private func createShapeLayers(_ shapeview: ShapeView?, _ path: UIBezierPath,
                                   color: UIColor, _ isSelected: Bool) -> CAShapeLayer? {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return nil}
        let shapeLayer = CAShapeLayer()
        let frame = isSelected ? tempViewFrame() : shapeview.frame
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

    private func replaceLayer(_ shapeview: ShapeView?, _ newLayer: CALayer) {
        guard let shapeview = shapeview else {return}
        shapeview.layer.sublayers?.removeAll()
        shapeview.layer.addSublayer(newLayer)
        changeSelectedPath(newLayer)
    }
    
    private func changeSelectedPath(_ newLayer: CALayer) {
        guard let menuShapeControl = self.menuShapeControl,
              let wallshapeview = menuShapeControl.wallshapeview,
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

    private func createPathPolygon(_ shapeview: ShapeView?, _ isSelected: Bool = false) {
        guard let shapeview = shapeview, let shape = shapeview.shape else {return}
        let vUInt = UInt32(shape.polygon * 10)
        guard let path = regularPolygonInRect(shapeview, vUInt, isSelected) else {return}
        changeShapeLayer(shapeview, path, isSelected)
    }

    private func pointFrom(_ angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
    }

    private func regularPolygonInRect(_ shapeview: ShapeView?, _ value: UInt32, _ isSelected: Bool) -> UIBezierPath? {
        guard let shapeview = shapeview else {return nil}
        let frame = isSelected ? tempViewFrame() : shapeview.frame
        let degree = value % 12 + 3
        let center = CGPoint(x: (frame.width/2) + frame.origin.x,
                             y: (frame.height/2) + frame.origin.y)
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
            self.createPolygon(shapeView, value, true)
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
              let wallshapeview = menuShapeControl.wallshapeview,
              let tempView = wallshapeview.tempView else {return}
        switch type {
        case .bringToFront:
            wallshapeview.insertSubview(tempView, at: wallshapeview.subviews.count - 1)
        case .bringForward:
            guard let index = wallshapeview.subviews.firstIndex(of: tempView) else { return }
            if index < wallshapeview.subviews.count {
                wallshapeview.insertSubview(tempView, at: index + 1)
            }
        case .sendToBack:
            wallshapeview.insertSubview(tempView, at: 1)
        case .sendBackward:
            guard let index = wallshapeview.subviews.firstIndex(of: tempView) else { return }
            if index > 1 {
                wallshapeview.insertSubview(tempView, at: index - 1)
            }
        }
    }
    
    func onShapeMenu(_ sender: TypeButton<ShapeMenuView>, shapeView: ShapeView) {
        guard let type = sender.type else {return}
        switch type {
        case .circle:
            self.createPath(shapeView, by: .circle, true)
        case .square:
            self.createPath(shapeView, by: .rectangle, true)
        case .triangle:
            self.createPath(shapeView, by: .triangle, true)
        case .polygon:
            guard let menuShapeControl = self.menuShapeControl,
                  let shape = shapeView.shape else {return}
            menuShapeControl.selectSlider(.polygon, value: Float(shape.polygon), sender.isSelected)
        }
    }
    
    private func cloneShapeView(_ shapeView: ShapeView) {
        guard let menuShapeControl = self.menuShapeControl else {return}
        menuShapeControl.hideSlider()
        menuShapeControl.hideMenuArrange()
        menuShapeControl.hideShapeMenu()
        guard let clonedShapeView = self.clone(shapeView) else {return}
        self.unselectView()
        menuShapeControl.selectShapeView(clonedShapeView)
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

extension ShapeViewControl {
    public func selectView(_ shapeView: ShapeView) {
        guard let menuShapeControl = self.menuShapeControl,
              let wallshapeview = menuShapeControl.wallshapeview,
              let tempView = wallshapeview.tempView,
              let selectBorder = wallshapeview.selectBorder,
              let shapelayer = selectBorder.firstSublayer as? CAShapeLayer,
              let currLayer = shapeView.firstSublayer else { return }
        CATransaction.removeAnimation {
            if let shplayer = currLayer as? CAShapeLayer {
                shapelayer.frame = shplayer.frame
                shapelayer.path = shplayer.path
            }
            if let gradient = currLayer as? CAGradientLayer,
               let shplayer = gradient.mask as? CAShapeLayer {
                shapelayer.frame = shplayer.frame
                shapelayer.path = shplayer.path
            }
            tempView.frame = shapeView.frame
            selectBorder.frame.size = shapeView.frame.size
            shapeView.frame.origin = CGPoint.zero
            wallshapeview.insertSubview(tempView, aboveSubview: shapeView)
            tempView.insertSubview(shapeView, belowSubview: selectBorder)
            _ = tempView.subviews.map {$0.isHidden = false}
        }
    }

    public func unselectView() {
        guard let menuShapeControl = self.menuShapeControl,
              let wallshapeview = menuShapeControl.wallshapeview,
              let tempView = wallshapeview.tempView else {return}
        let shapeView = (tempView.subviews.filter {type(of: $0) == ShapeView.self}).first
        guard let shapeview = shapeView as? ShapeView else {return}
        CATransaction.removeAnimation {
            shapeview.frame = tempView.frame
            wallshapeview.insertSubview(shapeview, aboveSubview: tempView)
            _ = tempView.subviews.map {$0.isHidden = true}
        }
    }
}
