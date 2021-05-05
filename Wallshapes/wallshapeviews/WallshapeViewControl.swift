//
//  WallshapeViewControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/20/21.
//

import UIKit

final class WallshapeViewControl {
    private var modelControl: ModelControl?
    private weak var view: WallshapeView?
    
    private var contentView: UIView?
    private var menuShapeView: MenuShapeView?
    
    init(_ view: WallshapeView) {
        self.view = view
        self.modelControl = ModelControl()
        
        guard let wallshape = self.modelControl?.recover() else { return }
        initContentView(with: wallshape.backgroundColors, size: wallshape.size)
        initMenu()
        initShapes(shapes: wallshape.shapes)
    }
    
    public func initShapes(shapes: [Shape]) {
        guard let view = self.view, let menuShapeView = self.menuShapeView else { return }
        menuShapeView.hideSlider()
        for shape in shapes {
            let frame = shape.frame
            let shapeView = ShapeView(frame: frame, menu: menuShapeView, shape: shape)
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
    
    //MARK: - Menu
    
    private func initMenu() {
        menuShapeView = MenuShapeView()
        guard let menuShapeView = self.menuShapeView else {return}
        menuShapeView.initMenu()
    }
    
    public func hideMenuShape() {
        menuShapeView?.hideMenu()
        menuShapeView?.hideSlider()
    }
    
    //MARK: - Colors
    
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
    
    //MARK: - Navigationbar Functions
    
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
        guard let view = self.view, let menuShapeView = self.menuShapeView else { return }
        menuShapeView.hideSlider()
        let size = view.bounds.width > view.bounds.height ? view.bounds.midY/2 : view.bounds.midX/2
        let frame = CGRect(x: size*1.75, y: size, width: size, height: size)
        let shapeView = ShapeView(frame: frame, menu: menuShapeView)
        shapeView.delegate = self
        view.addSubview(shapeView)
    }
    
    public func clearShapes() {
        guard let view = self.view else { return }
        view.subviews.forEach { if !$0.isEqual(contentView) { $0.removeFromSuperview() } }
        self.hideMenuShape()
    }
    
    public func contentViewFrame() -> CGRect {
        return self.contentView?.frame ?? CGRect.zero
    }
    
    //MARK: - Save file
    
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
        return view.subviews.filter{ type(of: $0) == ShapeView.self }.map{ $0 as! ShapeView }
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

extension WallshapeViewControl: ShapeViewDelegate {
    func deleteView(_ shapeView: ShapeView) {
        shapeView.removeFromSuperview()
        hideMenuShape()
    }
}
