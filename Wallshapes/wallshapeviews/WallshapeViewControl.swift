//
//  WallshapeViewControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/20/21.
//

import UIKit

final class WallshapeViewControl {
    private weak var view: WallshapeView?
    private var gridControl: GridControl?
    private var modelControl: ModelControl?
    private var menuShapeControl: MenuShapeControl?

    init(_ view: WallshapeView, menuControl: MenuShapeControl?) {
        self.view = view
        self.modelControl = ModelControl()
        self.menuShapeControl = menuControl
        
        guard let wallshape = self.modelControl?.recover() else { return }
        initContentView(with: wallshape.backgroundColors, size: wallshape.size)
        initShapes(shapes: wallshape.shapes)
        initGridView()
    }

    private func initShapes(shapes: [Shape]) {
        guard let view = self.view, let menuShapeControl = self.menuShapeControl else { return }
        for shape in shapes {
            let frame = shape.frame
            let shapeView = ShapeView(frame: frame, menu: menuShapeControl, shape: shape)
            shapeView.delegate = self
            view.addSubview(shapeView)
        }
    }

    private func initContentView(with colors: [UIColor], size: WallshapeSize) {
        guard let view = self.view else { return }
        guard let contentView = view.contentView else { return }
        if colors.count == 1 {
            contentView.backgroundColor = colors.first
        } else {
            addGradientLayer(with: colors)
        }
        if size == .small {
            resizeContentView()
        }
        view.addSubview(contentView)
    }

    private func initGridView() {
        guard let view = self.view, let contentView = view.contentView else { return }
        gridControl = GridControl(frame: contentView.bounds)
        guard let gridControl = self.gridControl, let shapelayer = gridControl.shapelayer else { return }
        gridControl.isHidden = true
        contentView.layer.addSublayer(shapelayer)
    }

    // MARK: - Colors

    public func chooseColors(_ count: Int) {
        let colors = self.randomColors(2)
        guard let gradientLayer = (self.view?.contentView?.layer.sublayers?.first) as? CAGradientLayer else {
            addGradientLayer(with: colors)
            return
        }
        let cgColors = colors.map{$0.cgColor}
        gradientLayer.colors = cgColors
    }

    public func chooseColor() {
        let color = UIColor.random
        self.view?.contentView?.layer.sublayers?.removeAll(where: { layer in layer is CAGradientLayer })
        self.view?.contentView?.backgroundColor = color
    }

    private func addGradientLayer(with colors: [UIColor]) {
        let gradientLayer = initGradientLayer(colors)
        self.view?.contentView?.layer.sublayers?.removeAll(where: { layer in layer is CAGradientLayer })
        self.view?.contentView?.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func initGradientLayer(_ colors: [UIColor]) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        let cgColors = colors.map{$0.cgColor}
        gradientLayer.frame = self.view?.contentView?.bounds ?? CGRect.zero
        gradientLayer.colors = cgColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }

    private func randomColors(_ count: Int = 2) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<count {
            let color = UIColor.random
            if !colors.contains(color) {
                colors.append(color)
            }
        }
        return colors
    }

    // MARK: - Navigationbar Functions

    public func gridView() {
        gridControl?.isHidden.toggle()
    }

    public func resizeContentView() {
        guard let view = self.view else { return }
        var newSize: CGRect = view.frame
        if view.contentView?.frame.height != view.contentView?.frame.width {
            newSize = CGRect(origin: CGPoint.zero, size: self.squaredSize())
        }
        self.view?.contentView?.frame.origin = CGPoint.zero
        self.view?.contentView?.frame.size = newSize.size
        self.view?.contentView?.center = view.center
        self.gridControl?.createGrid(frame: self.view?.contentView?.bounds)
        CATransaction.removeAnimation {
            self.view?.contentView?.layer.sublayers?.first?.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        }
    }

    private func squaredSize() -> CGSize {
        guard let view = self.view else { return CGSize.zero }
        let frame = min(view.frame.height, view.frame.width)
        return CGSize(width: frame/1.2, height: frame/1.2)
    }

    public func addShape() {
        guard let view = self.view, let menuShapeControl = self.menuShapeControl else { return }
        menuShapeControl.showMenu()
        let size = view.bounds.width > view.bounds.height ? view.bounds.midY/2 : view.bounds.midX/2
        let frame = CGRect(x: size*1.75, y: size, width: size, height: size)
        let shapeView = ShapeView(frame: frame, menu: menuShapeControl)
        shapeView.delegate = self
        view.addSubview(shapeView)
    }

    public func clearShapes() {
        guard let view = self.view else { return }
        view.subviews.forEach { if !$0.isEqual(view.contentView) { $0.removeFromSuperview() } }
        menuShapeControl?.hideMenu()
    }

    // MARK: - Save file

    public func saveFile() {
        modelControl?.wallshapeSize(contentViewSize())
        modelControl?.updateBackgroundColors(backgroundUIColors())
        modelControl?.addShapeViews(subShapeViews())
        modelControl?.save()
    }

    public func saveToPhotos(title: String) {
        guard let view = self.view, let contentView = view.contentView else {return}
        if let gridLayer = (contentView.layer.sublayers?.last) as? CAShapeLayer {
            gridLayer.removeFromSuperlayer()
        }
        SaveImage.save(title, view: view, frame: contentView.frame) {
            guard let gridControl = self.gridControl, let shapelayer = gridControl.shapelayer else { return }
            contentView.layer.addSublayer(shapelayer)
        }
    }

    private func contentViewSize() -> WallshapeSize {
        guard let view = self.view else { return .normal }
        if view.contentView?.frame.height ?? 0 < view.frame.height {
            return .small
        }
        return .normal
    }

    private func subShapeViews() -> [ShapeView] {
        guard let view = self.view else { return [] }
        return view.subviews
            .filter { type(of: $0) == ShapeView.self }
            .compactMap { $0 as? ShapeView }
    }

    private func backgroundUIColors() -> [UIColor] {
        if let sublayer = self.view?.contentView?.firstSublayer,
           let gradientLayer = sublayer as? CAGradientLayer,
           let colors = gradientLayer.colors,
           let cgColors = colors as? [CGColor] {
            return cgColors.map {UIColor(cgColor: $0)}
        }
        if let uicolors = self.view?.contentView?.backgroundColor {
            return [uicolors]
        }
        return []
    }
}

// MARK: - Menus

extension WallshapeViewControl: ShapeViewDelegate {
    func mainView(_ shapeView: ShapeView, _ sender: TypeButton<MainMenuView>) {
        guard let type = sender.type else {return}
        switch type {
        case .clone:
            cloneShapeView(shapeView)
        case .gradient:
            menuShapeControl?.hideSlider()
            menuShapeControl?.hideShapeMenu()
            menuShapeControl?.hideMenuArrange()
            shapeView.shapeViewControl?.createGradientColors()
        case .plainColor:
            menuShapeControl?.hideSlider()
            menuShapeControl?.hideShapeMenu()
            menuShapeControl?.hideMenuArrange()
            shapeView.shapeViewControl?.createPlainColor()
        case .shadow, .transparency:
            selectSlider(shapeView, type, isSelected: sender.isSelected)
        case .arrangeSet:
            menuShapeControl?.hideShapeMenu()
            menuShapeControl?.hideSlider()
            menuShapeControl?.showArrangeMenu()
        case .shapes:
            menuShapeControl?.hideMenuArrange()
            menuShapeControl?.hideSlider()
            menuShapeControl?.showShapeMenu()
        }
    }

    private func cloneShapeView(_ shapeView: ShapeView) {
        menuShapeControl?.hideSlider()
        menuShapeControl?.hideMenuArrange()
        menuShapeControl?.hideShapeMenu()
        guard let clonedShapeView = shapeView.shapeViewControl?.clone(self.menuShapeControl) else {return}
        clonedShapeView.delegate = self
        view?.addSubview(clonedShapeView)
    }

    private func selectSlider(_ shapeView: ShapeView, _ type: MainMenuTypeEnum, isSelected: Bool) {
        menuShapeControl?.hideMenuArrange()
        menuShapeControl?.hideShapeMenu()
        switch type {
        case .shadow:
            guard let value = shapeView.shapeViewControl?.shape?.shadowRadius else {return}
            menuShapeControl?.selectSlider(.shadow, value: Float(value), isSelected)
        case .transparency:
            guard let value = shapeView.shapeViewControl?.shape?.alpha else {return}
            menuShapeControl?.selectSlider(.alpha, value: Float(value), isSelected)
        default:
            NSLog("Error")
        }
    }
    
    func shapeView(_ shapeView: ShapeView, _ sender: TypeButton<ShapeMenuView>) {
        guard let type = sender.type else {return}
        menuShapeControl?.hideMenuArrange()
        menuShapeControl?.hideSlider()
        switch type {
        case .circle:
            shapeView.shapeViewControl?.createPath(by: .circle)
        case .square:
            shapeView.shapeViewControl?.createPath(by: .rectangle)
        case .triangle:
            shapeView.shapeViewControl?.createPath(by: .triangle)
        case .polygon:
            guard let value = shapeView.shapeViewControl?.shape?.polygon else {return}
            menuShapeControl?.selectSlider(.polygon, value: Float(value), sender.isSelected)
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
            shape.type = .polygon
        default:
            break
        }
    }
}
