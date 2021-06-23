//
//  GridControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 6/4/21.
//

import UIKit

final class GridControl {

    private let GAP: CGFloat = 20.0 // (gcf hxw)??
    private(set) var shapelayer: CAShapeLayer?
    var isHidden: Bool = true {
        didSet { shapelayer?.isHidden = isHidden }
    }

    init(frame: CGRect) {
        self.shapelayer = CAShapeLayer()
        self.createGrid(frame: frame)
    }

    public func createGrid(frame: CGRect?) {
        guard let shapelayer = self.shapelayer, let frame = frame else {return}
        shapelayer.strokeColor = UIColor.lightGray.cgColor
        shapelayer.lineWidth = 0.5
        sizePath(frame: frame)
    }

    private func sizePath(frame: CGRect) {
        let widhtLines = frame.size.width / GAP
        let heightLines = frame.size.height / GAP
        guard let shapelayer = self.shapelayer else {return}
        shapelayer.path = initGridPath(frame: frame, wLines: widhtLines, hLines: heightLines).cgPath
    }

    private func initGridPath(frame: CGRect, wLines: CGFloat, hLines: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        for idx in 1...Int(wLines) {
            path.move(to: CGPoint(x: CGFloat(idx) * GAP, y: frame.minX))
            path.addLine(to: CGPoint(x: CGFloat(idx) * GAP, y: frame.maxY))
        }
        for idx in 1...Int(hLines) {
            path.move(to: CGPoint(x: frame.minX, y: CGFloat(idx) * GAP))
            path.addLine(to: CGPoint(x: frame.maxX, y: CGFloat(idx) * GAP))
        }
        path.close()
        return path
    }
}
