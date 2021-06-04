//
//  IndicatorView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/19/21.
//

import UIKit

enum MiddleIndicatorViewType {
    case vertical, horizontal
}

class MiddleIndicatorView: UIView {
    init(frame: CGRect, type: MiddleIndicatorViewType) {
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

    private func initIndicatorView(type: MiddleIndicatorViewType) {
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
        path.addLine(to: CGPoint(x: frame.midX, y: frame.maxY*2))
        path.close()
        addShapeLayer(path)
    }

    private func initHorizontalIndicatorView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.minX, y: frame.midY))
        path.addLine(to: CGPoint(x: frame.maxX*2, y: frame.midY))
        path.close()
        addShapeLayer(path)
    }

    private func addShapeLayer(_ path: UIBezierPath) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = frame
        shapeLayer.strokeColor = UIColor.yellow.cgColor
        shapeLayer.lineDashPattern = [2, 5]
        shapeLayer.lineWidth = 2
        shapeLayer.path = path.cgPath
        self.layer.addSublayer(shapeLayer)
    }
}
