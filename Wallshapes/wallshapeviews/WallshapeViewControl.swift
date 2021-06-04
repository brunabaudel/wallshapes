//
//  WallshapeViewControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/20/21.
//

import UIKit

final class WallshapeViewControl {
    private weak var view: WallshapeView?
    private var contentView: UIView?

    private var modelControl: ModelControl?
    private var menuShapeControl: MenuShapeControl?

    init(_ view: WallshapeView, menuControl: MenuShapeControl?) {
        self.view = view
        self.modelControl = ModelControl()
        self.menuShapeControl = menuControl

        guard let wallshape = self.modelControl?.recover() else { return }
        initContentView(with: wallshape.backgroundColors, size: wallshape.size)
        initShapes(shapes: wallshape.shapes)
    }

    public func initShapes(shapes: [Shape]) {
        guard let view = self.view, let menuShapeControl = self.menuShapeControl else { return }
        for shape in shapes {
            let frame = shape.frame
            let shapeView = ShapeView(frame: frame, menu: menuShapeControl, shape: shape)
            shapeView.delegate = self
            view.addSubview(shapeView)
        }
    }

    public func initContentView(with colors: [CGColor], size: WallshapeSize) {
        guard let view = self.view else { return }
        contentView = UIView(frame: view.frame)
        guard let contentView = self.contentView else { return }
        if colors.count == 1 {
            contentView.backgroundColor = UIColor(cgColor: colors.first!)
        } else {
            addGradientLayer(with: colors)
        }
        if size == .small {
            resizeContentView()
        }
        view.addSubview(contentView)
    }

    // MARK: - Colors

    public func chooseColors(_ count: Int) {
        let colors = self.randomColors(2)
        guard let gradientLayer = (contentView?.layer.sublayers?.first) as? CAGradientLayer else {
            addGradientLayer(with: colors)
            return
        }
        gradientLayer.colors = colors
    }

    public func chooseColor() {
        let color = UIColor.random
        contentView?.layer.sublayers?.removeAll()
        contentView?.backgroundColor = color
    }

    private func addGradientLayer(with colors: [CGColor]) {
        let gradientLayer = initGradientLayer(colors)
        contentView?.layer.sublayers?.removeAll()
        contentView?.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func initGradientLayer(_ colors: [CGColor]) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView?.bounds ?? CGRect.zero
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }

    private func randomColors(_ count: Int = 2) -> [CGColor] {
        var colors: [CGColor] = []
        for _ in 0..<count {
            let color = UIColor.random.cgColor
            if !colors.contains(color) {
                colors.append(color)
            }
        }
        return colors
    }

    // MARK: - Navigationbar Functions

    public func resizeContentView() {
        guard let view = self.view else { return }
        var newSize: CGRect = view.frame
        if contentView?.frame.height != contentView?.frame.width {
            newSize = CGRect(origin: CGPoint.zero, size: self.squaredSize())
        }
        contentView?.frame.origin = CGPoint.zero
        contentView?.frame.size = newSize.size
        contentView?.center = view.center
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contentView?.layer.sublayers?.first?.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        CATransaction.commit()
    }

    private func squaredSize() -> CGSize {
        guard let view = self.view else { return CGSize.zero }
        let frame = min(view.frame.height, view.frame.width)
        return CGSize(width: frame/1.2, height: frame/1.2)
    }

    public func addShape() {
        guard let view = self.view, let menuShapeControl = self.menuShapeControl else { return }
        menuShapeControl.showMenuShape()
        let size = view.bounds.width > view.bounds.height ? view.bounds.midY/2 : view.bounds.midX/2
        let frame = CGRect(x: size*1.75, y: size, width: size, height: size)
        let shapeView = ShapeView(frame: frame, menu: menuShapeControl)
        shapeView.delegate = self
        view.addSubview(shapeView)
    }

    public func clearShapes() {
        guard let view = self.view else { return }
        view.subviews.forEach { if !$0.isEqual(contentView) { $0.removeFromSuperview() } }
        menuShapeControl?.hideMenuShape()
    }

    public func contentViewFrame() -> CGRect {
        return self.contentView?.frame ?? CGRect.zero
    }

    // MARK: - Save file

    public func saveFile() {
        modelControl?.wallshapeSize(contentViewSize())
        modelControl?.updateBackgroundColors(backgroundCGColors())
        modelControl?.addShapeViews(subShapeViews())
        modelControl?.save()
    }

    private func contentViewSize() -> WallshapeSize {
        guard let view = self.view else { return .normal }
        if contentView?.frame.height ?? 0 < view.frame.height {
            return .small
        }
        return .normal
    }

    private func subShapeViews() -> [ShapeView] {
        guard let view = self.view else { return [] }
        return view.subviews
            .filter { type(of: $0) == ShapeView.self }
            .compactMap {
                if let shapeview = $0 as? ShapeView { return shapeview }
                return nil
            }
    }

    private func backgroundCGColors() -> [CGColor] {
        if let sublayer = contentView?.firstSublayer {
            if let colors = (sublayer as? CAGradientLayer)?.colors,
               let cgColors = colors as? [CGColor],
               sublayer.isEqualTo(type: CAGradientLayer.self) {
                return cgColors
            }
        } else {
            if let cgColors = contentView?.backgroundColor?.cgColor {
                return [cgColors]
            }
        }
        return []
    }
}

// MARK: - Menus

extension WallshapeViewControl: ShapeViewDelegate {
    func mainView(_ shapeView: ShapeView, _ sender: TypeButton<MenuMainView>) {
        guard let type = sender.type else {return}
        switch type {
        case .clone:
            cloneShapeView(shapeView)
        case .circle, .square, .triangle:
            changeShapeView(shapeView, by: type)
        case .gradient:
            menuShapeControl?.hideSlider()
            menuShapeControl?.hideMenuArrange()
            shapeView.shapeViewControl?.createGradientColors()
        case .plainColor:
            menuShapeControl?.hideSlider()
            menuShapeControl?.hideMenuArrange()
            shapeView.shapeViewControl?.createPlainColor()
        case .shadow, .transparency, .polygon:
            selectSlider(shapeView, type, isSelected: sender.isSelected)
        case .arrangeSet:
            menuShapeControl?.hideSlider()
            menuShapeControl?.showArrangeMenu()
        }
    }

    private func cloneShapeView(_ shapeView: ShapeView) {
        menuShapeControl?.hideSlider()
        menuShapeControl?.hideMenuArrange()
        guard let clonedShapeView = shapeView.shapeViewControl?.clone(self.menuShapeControl) else {return}
        clonedShapeView.delegate = self
        view?.addSubview(clonedShapeView)
    }

    private func changeShapeView(_ shapeView: ShapeView, by type: MenuMainTypeEnum) {
        menuShapeControl?.hideSlider()
        menuShapeControl?.hideMenuArrange()
        switch type {
        case .circle:
            shapeView.shapeViewControl?.createPath(by: .circle)
        case .square:
            shapeView.shapeViewControl?.createPath(by: .rectangle)
        case .triangle:
            shapeView.shapeViewControl?.createPath(by: .triangle)
        default:
            NSLog("Error")
        }
    }

    private func selectSlider(_ shapeView: ShapeView, _ type: MenuMainTypeEnum, isSelected: Bool) {
        menuShapeControl?.hideMenuArrange()
        switch type {
        case .shadow:
            guard let value = shapeView.shapeViewControl?.shape?.shadowRadius else {return}
            menuShapeControl?.selectSlider(.shadow, value: Float(value), isSelected)
        case .transparency:
            guard let value = shapeView.shapeViewControl?.shape?.alpha else {return}
            menuShapeControl?.selectSlider(.alpha, value: Float(value), isSelected)
        case .polygon:
            guard let value = shapeView.shapeViewControl?.shape?.polygon else {return}
            menuShapeControl?.selectSlider(.polygon, value: Float(value), isSelected)
        default:
            NSLog("Error")
        }
    }

    func arrangeView(_ shapeView: ShapeView, _ sender: TypeButton<ArrangeMenuView>) {
        guard let view = self.view, let type = sender.type else {return}
        switch type {
        case .bringToFront:
            view.insertSubview(shapeView, at: view.subviews.count - 1)
        case .bringForward:
            guard let index = view.subviews.firstIndex(of: shapeView) else { return }
            if index < view.subviews.count {
                view.insertSubview(shapeView, at: index + 1)
            }
        case .sendToBack:
            view.insertSubview(shapeView, at: 1)
        case .sendBackward:
            guard let index = view.subviews.firstIndex(of: shapeView) else { return }
            if index > 1 {
                view.insertSubview(shapeView, at: index - 1)
            }
        }
    }

    func sliderView(_ shapeView: ShapeView, _ sender: SliderMenu) {
        guard let shape = shapeView.shapeViewControl?.shape else {return}
        switch sender.type {
        case .shadow:
            let value = CGFloat(sender.value)
            shapeView.shapeViewControl?.createShadow(value)
            shape.shadowRadius = value
        case .alpha:
            let value = CGFloat(sender.value)
            shapeView.shapeViewControl?.createAlpha(value)
            shape.alpha = value
        case .polygon:
            let value = CGFloat(sender.value)
            shapeView.shapeViewControl?.createPolygon(value)
            shape.polygon = value
        default:
            break
        }
    }
}
