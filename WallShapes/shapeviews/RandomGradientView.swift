//
//  RandomGradientView.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class RandomGradientView: UIView {
    private var gradientLayer: CAGradientLayer?
    private var menuShapeView: MenuShapeView?
    private var shapeViews: [ShapeView] = []
    
    private var gesturesControl: ShapeGesturesControl?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.gesturesControl = ShapeGesturesControl(self)
        
        initGradientLayer()
        initMenu()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func chooseColors(_ count: Int) {
        gradientLayer?.colors = self.setGradient(count)
        gradientLayer?.locations = nil
    }
    
    public func chooseColor() {
        gradientLayer?.colors = [UIColor.random().cgColor, UIColor.white.cgColor]
        gradientLayer?.locations = [1]
    }

    fileprivate func initGradientLayer() {
        gradientLayer = CAGradientLayer()
        guard let gradientLayer = self.gradientLayer else {return}
        gradientLayer.frame = self.bounds
        gradientLayer.colors = setGradient()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    fileprivate func setGradient(_ count: Int = 2) -> [CGColor] {
        var colors: [CGColor] = []
        for _ in 0..<count {
            let color = UIColor.random().cgColor
            if !colors.contains(color) {
                colors.append(color)
            }
        }
        return colors
    }
}

extension RandomGradientView {
    public func addShape() {
        guard let menuShapeView = self.menuShapeView else {return}
        menuShapeView.hideSlider()
        let shape = ShapeView(frame: CGRect(origin: CGPoint(x: 16, y: 100),
                                            size: CGSize(width: self.bounds.midX/2, height: self.bounds.midX/2)),
                              menu: menuShapeView)
        shape.delegate = self
        shapeViews.append(shape)
        self.addSubview(shape)
    }
    
    public func clearShapes() {
        self.shapeViews.removeAll()
        self.subviews.forEach { $0.removeFromSuperview() }
    }
}

extension RandomGradientView: ShapeViewDelegate {
    func deleteView(_ shapeView: ShapeView) {
        self.shapeViews.remove(object: shapeView)
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
        
        guard let window = UIApplication.window() else {return}
        window.addSubview(menuShapeView)
        
        menuShapeView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
        menuShapeView.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        menuShapeView.heightAnchor.constraint(equalTo: window.heightAnchor, multiplier: 0.5).isActive = true
        menuShapeView.widthAnchor.constraint(equalTo: window.widthAnchor, multiplier: 0.1).isActive = true
    }
    
    public func hideMenuShape() {
        self.menuShapeView?.hideMenu()
        self.menuShapeView?.hideSlider()
    }
    
    }
}
