//
//  MiddleIndicatorView.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/19/21.
//

import UIKit

class HMiddleIndicatorView: MiddleIndicatorView {
    override func initIndicatorView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.minX, y: frame.midY))
        path.addLine(to: CGPoint(x: frame.maxX, y: frame.midY))
        path.close()
        addShapeLayer(path)
    }
}

class VMiddleIndicatorView: MiddleIndicatorView {
    override func initIndicatorView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.midX, y: frame.minY))
        path.addLine(to: CGPoint(x: frame.midX, y: frame.maxY))
        path.close()
        addShapeLayer(path)
    }
}

class MiddleIndicatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isHidden = true
        initIndicatorView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initIndicatorView()
    }
    
    internal func initIndicatorView() {}
    
    public func toggle(_ isHidden: Bool) {
        self.isHidden = !isHidden
    }
    
    internal func addShapeLayer(_ path: UIBezierPath) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = self.bounds
        shapeLayer.position = self.center
        shapeLayer.strokeColor = UIColor.yellow.cgColor
        shapeLayer.lineDashPattern = [2,5]
        shapeLayer.lineWidth = 3
        shapeLayer.path = path.cgPath
        self.layer.addSublayer(shapeLayer)
    }
}
