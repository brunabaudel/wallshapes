//
//  IndicatorView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/19/21.
//

import UIKit

enum IndicatorViewType {
    case vertical, horizontal
}

class IndicatorView: UIView {
    init(frame: CGRect, type: IndicatorViewType) {
        super.init(frame: frame)
        backgroundColor = .clear
        isHidden = true
        initIndicatorView(type: type)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isHidden = true
    }
    
    public func toggle(_ isHidden: Bool) {
        self.isHidden = !isHidden
    }
    
    private func initIndicatorView(type: IndicatorViewType) {
        switch type {
        case .vertical:
            self.initVerticalIndicatorView()
        case .horizontal:
            self.initHorizontalIndicatorView()
        }
    }
    
    private func initVerticalIndicatorView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.midX, y: frame.minY))
        path.addLine(to: CGPoint(x: frame.midX, y: frame.maxY))
        path.close()
        addShapeLayer(path)
    }
    
    private func initHorizontalIndicatorView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.minX, y: frame.midY))
        path.addLine(to: CGPoint(x: frame.maxX, y: frame.midY))
        path.close()
        addShapeLayer(path)
    }
    
    private func addShapeLayer(_ path: UIBezierPath) {
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
