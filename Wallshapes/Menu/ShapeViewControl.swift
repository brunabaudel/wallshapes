//
//  ShapeViewControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/19/21.
//

import UIKit

final class ShapeViewControl {
    private weak var menuShapeControl: MenuShapeControl?
    private var layoutShapeView: LayoutShapeView?

    init(_ menuShapeControl: MenuShapeControl) {
        self.menuShapeControl = menuShapeControl
        self.menuShapeControl?.delegate = self
        guard let menu = self.menuShapeControl else {return}
        self.layoutShapeView = LayoutShapeView(menu: menu)
    }

    public func createShapeView(_ shapeview: ShapeView) {
        guard let layout = self.layoutShapeView, let shape = shapeview.shape,
              let type = shape.type else {return}
        layout.createPath(shapeview, by: type)
        self.createAlpha(shapeview, shape.alpha)
        self.createShadow(shapeview, shape.shadowRadius)
    }

    private func createPlainColor(_ shapeview: ShapeView) {
        guard let shape = shapeview.shape, let shapeLayer = shape.shapeLayer else {return}
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

    private func createGradientColors(_ shapeview: ShapeView) {
        guard let shape = shapeview.shape, let shapeLayer = shape.shapeLayer else {return}
        if let gradient = shape.gradientLayer {
            let colors = [UIColor.random, UIColor.random]
            self.replaceGradientLayer(shapeview, shapeLayer, gradient, colors: colors)
        }
        let gradient = CAGradientLayer()
        shapeLayer.fillColor = UIColor.white.cgColor
        gradient.bounds = shapeview.bounds
        gradient.position = CGPoint(x: shapeview.bounds.midX, y: shapeview.bounds.midY)
        guard let colors = shape.layerColors else {return}
        self.replaceGradientLayer(shapeview, shapeLayer, gradient, colors: colors)
    }

    private func createShadow(_ shapeview: ShapeView, _ value: CGFloat) {
        guard let shape = shapeview.shape else {return}
        shapeview.layer.shadowRadius = value * 100
        shapeview.layer.shadowOpacity = 0.5
        shapeview.layer.shadowOffset = .zero
        shapeview.layer.shadowColor = UIColor.black.cgColor
        shapeview.layer.shouldRasterize = true
        shapeview.layer.rasterizationScale = UIScreen.main.scale
        if value == 0 { shapeview.layer.shadowColor = UIColor.clear.cgColor }
        shape.shadowRadius = value
    }

    private func createAlpha(_ shapeview: ShapeView, _ value: CGFloat) {
        guard let shape = shapeview.shape else {return}
        shape.alpha = value
        shapeview.alpha = value
    }

    private func createPolygon(_ shapeview: ShapeView, _ value: CGFloat, _ isSelected: Bool = false) {
        guard let layout = self.layoutShapeView, let shape = shapeview.shape else {return}
        let vUInt = UInt32(value * 10)
        layout.changePolygon(shapeview, value: vUInt, isSelected: isSelected)
        shape.polygon = value
    }

    private func clone(_ shapeview: ShapeView) -> ShapeView? {
        guard let shape = shapeview.shape,
              let menuShapeControl = self.menuShapeControl,
              let view = menuShapeControl.wallshapeview,
              let tempview = view.tempView else {return nil}
        let clonedShape = Shape()
        clonedShape.alpha = shape.alpha
        clonedShape.layerColors = shape.layerColors
        clonedShape.layerType = shape.layerType
        clonedShape.polygon = shape.polygon
        clonedShape.shadowRadius = shape.shadowRadius
        clonedShape.frame = tempview.frame
        clonedShape.type = shape.type
        let clonedShapeView = ShapeView(shape: clonedShape)
        self.createShapeView(clonedShapeView)
        return clonedShapeView
    }
    
    private func replaceLayer(_ shapeview: ShapeView, _ newLayer: CALayer) {
        shapeview.layer.sublayers?.removeAll()
        shapeview.layer.addSublayer(newLayer)
    }
    
    private func replaceGradientLayer(_ shapeview: ShapeView, _ shapeLayer: CAShapeLayer,
                                      _ gradient: CAGradientLayer, colors: [UIColor]) {
        guard let shape = shapeview.shape else {return}
        let cgColors = colors.map {$0.cgColor}
        gradient.colors = cgColors
        gradient.mask = shapeLayer
        self.replaceLayer(shapeview, gradient)
        shape.gradientLayer = gradient
        shape.layerColors = colors
        shape.layerType = CAGradientLayer.self
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
        guard let type = sender.type, let menu = self.menuShapeControl,
              let layout = self.layoutShapeView else {return}
        switch type {
        case .circle:
            menu.hideSlider()
            layout.createPath(shapeView, by: .circle, true)
        case .square:
            menu.hideSlider()
            layout.createPath(shapeView, by: .rectangle, true)
        case .triangle:
            menu.hideSlider()
            layout.createPath(shapeView, by: .triangle, true)
        case .polygon:
            guard let shape = shapeView.shape else {return}
            menu.selectSlider(.polygon, value: Float(shape.polygon), sender.isSelected)
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

// MARK: - Select and Unselect

extension ShapeViewControl {
    public func selectView(_ shapeView: ShapeView) {
        guard let menuShapeControl = self.menuShapeControl,
              let wallshapeview = menuShapeControl.wallshapeview,
              let tempView = wallshapeview.tempView,
              let selectBorder = wallshapeview.selectBorder,
              let shapelayer = selectBorder.firstSublayer as? CAShapeLayer,
              let currLayer = shapeView.firstSublayer,
              let isDeleteActive = wallshapeview.isDeleteActive else {return}
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
            wallshapeview.selectedIndex = (wallshapeview.subviews.firstIndex(of: tempView) ?? 1)
            if isDeleteActive {
                menuShapeControl.hideMenu()
                wallshapeview.insertSubview(tempView, at: wallshapeview.subviews.count)
            }
        }
        wallshapeview.isSelected = true
    }

    public func unselectView() {
        guard let menuShapeControl = self.menuShapeControl,
              let wallshapeview = menuShapeControl.wallshapeview,
              let tempView = wallshapeview.tempView,
              let isDeleteActive = wallshapeview.isDeleteActive,
              let selectedIndex = wallshapeview.selectedIndex else {return}
        let shapeView = (tempView.subviews.filter {type(of: $0) == ShapeView.self}).first
        guard let shapeview = shapeView as? ShapeView else {return}
        CATransaction.removeAnimation {
            shapeview.frame = tempView.frame
            if !isDeleteActive {
                wallshapeview.insertSubview(shapeview, aboveSubview: tempView)
            } else {
                menuShapeControl.hideMenu()
                wallshapeview.insertSubview(shapeview, at: selectedIndex)
            }
            _ = tempView.subviews.map {$0.isHidden = true}
        }
        wallshapeview.isSelected = false
    }
}
