//
//  WallshapeView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class WallshapeView: UIView {
    private var wallshapeViewControl: WallshapeViewControl?
    private var gesturesControl: ShapeGesturesControl?
    private var modelControl: ModelControl?
    
    private(set) var contentView: UIView!
    private var menuShapeView: MenuShapeView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.modelControl = ModelControl()
        self.gesturesControl = ShapeGesturesControl(self)
        self.backgroundColor = .init(white: 0.15, alpha: 1)
        
        guard let wallshape = self.modelControl?.recover() else { return }
        initContentView(with: wallshape.backgroundColors, size: wallshape.size)
        initMenu()
        initShapes(shapes: wallshape.shapes)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func chooseColors(_ count: Int) {
        let colors = self.randomColors(2)
        guard let gradientLayer = (contentView.layer.sublayers?.first) as? CAGradientLayer else {
            addGradientLayer(with: colors)
            return
        }
        gradientLayer.colors = colors
    }
    
    public func chooseColor() {
        let color = UIColor.random
        contentView.layer.sublayers?.removeAll()
        contentView.backgroundColor = color
    }

    private func initShapes(shapes: [Shape]) {
        guard let menuShapeView = self.menuShapeView else { return }
        menuShapeView.hideSlider()
        for shape in shapes {
            let frame = CGRect(origin: shape.origin, size: shape.size)
            let shapeView = ShapeView(frame: frame, menu: menuShapeView, shape: shape)
            shapeView.delegate = self
            addSubview(shapeView)
        }
    }
    
    private func initContentView(with colors: [CGColor], size: WallshapeSize) {
        contentView = UIView(frame: self.frame)
        if colors.count == 1 {
            contentView.backgroundColor = UIColor(cgColor: colors.first!)
        } else {
            addGradientLayer(with: colors)
        }
        if size == .small {
            resizeContentView()
        }
        addSubview(contentView)
    }
    
    private func addGradientLayer(with colors: [CGColor]) {
        let gradientLayer = initGradientLayer(colors)
        contentView.layer.sublayers?.removeAll()
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func initGradientLayer(_ colors: [CGColor]) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.frame
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
    
    public func resizeContentView() {
        var newSize: CGRect = self.frame
        if contentView.frame.height != contentView.frame.width {
            newSize = CGRect(origin: CGPoint.zero, size: self.squaredSize())
        }
        contentView.frame.origin = CGPoint.zero
        contentView.frame.size = newSize.size
        contentView.center = self.center
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contentView.layer.sublayers?.first?.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        CATransaction.commit()
    }
    
    private func squaredSize() -> CGSize {
        let frame = min(self.frame.height, self.frame.width)
        return CGSize(width: frame/1.2, height: frame/1.2)
    }
    
    public func addShape() {
        guard let menuShapeView = self.menuShapeView else {return}
        menuShapeView.hideSlider()
        let size = bounds.width > bounds.height ? bounds.midY/2 : bounds.midX/2
        let frame = CGRect(x: size*1.75, y: size, width: size, height: size)
        let shapeView = ShapeView(frame: frame, menu: menuShapeView)
        shapeView.delegate = self
        addSubview(shapeView)
    }
    
    public func clearShapes() {
        subviews.forEach { if !$0.isEqual(contentView) { $0.removeFromSuperview() } }
        hideMenuShape()
    }
    
    public func saveFile() {
        modelControl?.wallshapeSize(contentViewSize())
        modelControl?.updateBackgroundColors(backgroundCGColors())
        modelControl?.addShapeViews(subShapeViews())
        modelControl?.save()
    }
    
    private func contentViewSize() -> WallshapeSize {
        if contentView.frame.height < frame.height {
            return .small
        }
        return .normal
    }
    
    private func subShapeViews() -> [ShapeView] {
        return subviews.filter{ type(of: $0) == ShapeView.self }.map{ $0 as! ShapeView }
    }
    
    private func backgroundCGColors() -> [CGColor] {
        if let sublayer = contentView.firstSublayer {
            if let colors = (sublayer as? CAGradientLayer)?.colors,
               let cgColors = colors as? [CGColor],
               sublayer.isEqualTo(type: CAGradientLayer.self) {
                return cgColors
            }
        } else {
            if let cgColors = contentView.backgroundColor?.cgColor {
                return [cgColors]
            }
        }
        return []
    }
}

extension WallshapeView: ShapeViewDelegate {
    func deleteView(_ shapeView: ShapeView) {
        shapeView.removeFromSuperview()
        hideMenuShape()
    }
}

//MARK: - Menu

extension WallshapeView {
    private func initMenu() {
        menuShapeView = MenuShapeView()
        guard let menuShapeView = self.menuShapeView else {return}
        menuShapeView.initMenu()
    }
    
    public func hideMenuShape() {
        menuShapeView?.hideMenu()
        menuShapeView?.hideSlider()
    }
}
