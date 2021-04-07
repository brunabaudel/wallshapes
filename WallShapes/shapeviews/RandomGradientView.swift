//
//  RandomGradientView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class RandomGradientView: UIView {
    private var randomBackgroundView: UIView!
    private var gesturesControl: ShapeGesturesControl?
    private var menuShapeView: MenuShapeView?
    private var shapeViews: [ShapeView] = []
    
    public var horizontalIndicatorView: IndicatorView!
    public var verticalIndicatorView: IndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.gesturesControl = ShapeGesturesControl(self)
        self.backgroundColor = .init(white: 0.15, alpha: 1)
        
        initGradientLayer()
        initIndicator()
        initMenu()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func chooseColors(_ count: Int) {
        let layer = (randomBackgroundView.layer.sublayers?[0]) as? CAGradientLayer
        layer?.colors = self.setGradient(count)
        layer?.locations = nil
    }

    public func chooseColor() {
        let layer = (randomBackgroundView.layer.sublayers?[0]) as? CAGradientLayer
        layer?.colors = [UIColor.random.cgColor, UIColor.white.cgColor]
        layer?.locations = [1]
    }

    fileprivate func initGradientLayer() {
        randomBackgroundView = UIView(frame: self.frame)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = setGradient()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        randomBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        addSubview(randomBackgroundView)
    }

    fileprivate func setGradient(_ count: Int = 2) -> [CGColor] {
        var colors: [CGColor] = []
        for _ in 0..<count {
            let color = UIColor.random.cgColor
            if !colors.contains(color) {
                colors.append(color)
            }
        }
        return colors
    }
    
    private func initIndicator() {
        guard let window = UIApplication.window else {return}
        self.verticalIndicatorView = IndicatorView(frame: CGRect(x: frame.midX/3,
                                                                 y: frame.minY,
                                                                 width: 10,
                                                                 height: frame.height),
                                                   type: IndicatorViewType.vertical)
        
        self.horizontalIndicatorView = IndicatorView(frame: CGRect(x: frame.minX,
                                                                   y: frame.midY/3,
                                                                   width: frame.width,
                                                                   height: 10),
                                                     type: IndicatorViewType.horizontal)
        window.addSubview(verticalIndicatorView)
        window.addSubview(horizontalIndicatorView)
    }
    
    public func resizeRandomBackgroundView() {
        var newSize: CGRect = self.frame
        if randomBackgroundView.frame.height != randomBackgroundView.frame.width {
            newSize = CGRect(origin: CGPoint.zero, size: self.size())
        }
        randomBackgroundView.frame.origin = CGPoint.zero
        randomBackgroundView.frame.size = newSize.size
        randomBackgroundView.center = self.center
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        randomBackgroundView.layer.sublayers?[0].frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        CATransaction.commit()
    }
    
    private func size() -> CGSize {
        let frame = min(self.frame.height, self.frame.width)
        return CGSize(width: frame/1.2, height: frame/1.2)
    }
    
    public func randomBackgroundViewFrame() -> CGRect {
        return randomBackgroundView.frame
    }
}

extension RandomGradientView {
    public func addShape() {
        guard let menuShapeView = self.menuShapeView else {return}
        menuShapeView.hideSlider()
        let size = bounds.width > bounds.height ? bounds.midY/2 : bounds.midX/2
        let shape = ShapeView(frame: CGRect(x: size*1.75, y: size, width: size, height: size), menu: menuShapeView)
        shape.delegate = self
        shapeViews.append(shape)
        addSubview(shape)
    }
    
    public func clearShapes() {
        shapeViews.removeAll()
        subviews.forEach { if !$0.isEqual(randomBackgroundView) { $0.removeFromSuperview() } }
        hideMenuShape()
    }
}

extension RandomGradientView: ShapeViewDelegate {
    func deleteView(_ shapeView: ShapeView) {
        shapeViews.remove(object: shapeView)
        shapeView.removeFromSuperview()
        hideMenuShape()
    }
}

//MARK: - Menu

extension RandomGradientView {
    private func initMenu() {
        menuShapeView = MenuShapeView()
        guard let menuShapeView = self.menuShapeView else {return}
        menuShapeView.translatesAutoresizingMaskIntoConstraints = false
        menuShapeView.isHidden = true
        
        guard let window = UIApplication.window else {return}
        window.addSubview(menuShapeView)
        menuSizeCConstraints()
    }
    
    private func menuSizeCConstraints() {
        guard let window = UIApplication.window else {return}
        guard let menuShapeView = self.menuShapeView else {return}
        menuShapeView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
        menuShapeView.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        menuShapeView.heightAnchor.constraint(equalTo: (window.frame.width > window.frame.height) ? window.widthAnchor : window.heightAnchor, multiplier: 0.5).isActive = true
        menuShapeView.widthAnchor.constraint(equalTo: (window.frame.width > window.frame.height) ? window.heightAnchor : window.widthAnchor, multiplier: 0.1).isActive = true
    }
    
    public func hideMenuShape() {
        menuShapeView?.hideMenu()
        menuShapeView?.hideSlider()
    }
}
