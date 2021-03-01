//
//  ShapeGesturesControl.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

protocol ShapeGesturesControlDelegate {
    func didOnTap()
    func didOnPan()
}

class ShapeGesturesControl {
    var delegate: ShapeGesturesControlDelegate?
    
    var view: RandomGradientView //TODO: change to UIView and change the onTap function
    var viewGesture: ShapeView?
    var shapeLayerPath: CGPath?
    
    init<T: RandomGradientView>(_ view: T) {
        self.view = view
        initGestures()
    }
}

extension ShapeGesturesControl {
    func initGestures() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didOnPan(_:)))
        self.view.addGestureRecognizer(panGR)
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(didOnTap(_:)))
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func didOnPan(_ recognizer: UIPanGestureRecognizer) {
        didPan(recognizer)
        delegate?.didOnPan()
    }
    
    @objc func didOnTap(_ recognizer: UITapGestureRecognizer) {
        didTap(recognizer)
        delegate?.didOnTap()
    }
}

extension ShapeGesturesControl {
    func didTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.view)
        self.findSubview(location)
        guard let viewGesture = self.viewGesture else {
            self.view.hideMenuShape()
            return
        }
        self.view.bringSubviewToFront(viewGesture)
        viewGesture.showMenuShape()
        self.clearSubview()
    }
}

extension ShapeGesturesControl {
    func didPan(_ recognizer: UIPanGestureRecognizer) {
        switch (recognizer.state) {
            case .began:
                let location = recognizer.location(in: self.view)
                self.findSubview(location)
                self.viewGesture?.showMenuShape()
            case .changed:
                guard let viewGesture = self.viewGesture else {return}
                var translation = recognizer.translation(in: viewGesture)
                translation = translation.applying(viewGesture.transform)
                viewGesture.center.x += translation.x
                viewGesture.center.y += translation.y
                self.shapeLayerPath = self.shapeLayerPath?.translate(translation)
                recognizer.setTranslation(CGPoint.zero, in: viewGesture)
            case .ended, .cancelled:
                self.updateShapeLayerFrameTranslate()
                self.clearSubview()
            default:
                break
        }
    }
    
    func updateShapeLayerFrameTranslate() {
        guard let viewGesture = self.viewGesture else {return}
        guard let currLayer = viewGesture.firstSublayer() else {return}
        let newFrame = self.view.convert(self.view.bounds, from: viewGesture)
        if type(of: currLayer).isEqual(CAShapeLayer.self) {
            setupShapeLayer(newFrame, currLayer: currLayer as! CAShapeLayer)
        }
        if type(of: currLayer).isEqual(CAGradientLayer.self) {
            setupGradientLayer(newFrame, currLayer: currLayer as! CAGradientLayer)
        }
    }
    
    func setupShapeLayer(_ newFrame: CGRect, currLayer: CAShapeLayer) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        currLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: self.view.bounds.size)
        currLayer.path = self.shapeLayerPath
        CATransaction.commit()
    }
    
    func setupGradientLayer(_ newFrame: CGRect, currLayer: CAGradientLayer) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let shapeLayer = currLayer.mask as! CAShapeLayer
        shapeLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: self.view.bounds.size)
        shapeLayer.path = self.shapeLayerPath
        currLayer.mask = shapeLayer
        CATransaction.commit()
    }
    
    func findSubview(_ location: CGPoint) {
        for subview in self.view.subviews.reversed() {
            guard let currLayer = subview.firstSublayer() else {return}
            let subviewLoc = subview.frame.contains(location)
            let layerLoc = currLayer.contains(location)
            if subviewLoc && layerLoc {
                self.viewGesture = subview as? ShapeView
                self.shapeLayerPath = currLayer.layerMutableCopy()
                break
            }
        }
    }
    
    func clearSubview() {
        self.viewGesture = nil
        self.shapeLayerPath = nil
    }
}
