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
    internal var delegate: ShapeGesturesControlDelegate?
    
    private weak var view: RandomGradientView? //TODO: change to UIView and change the onTap function
    private var viewGesture: ShapeView?
    private var shapeLayerPath: CGPath?
    
    init<T: RandomGradientView>(_ view: T) {
        self.view = view
        initGestures()
    }
}

extension ShapeGesturesControl {
    private func initGestures() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didOnPan(_:)))
        self.view?.addGestureRecognizer(panGR)
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(didOnTap(_:)))
        self.view?.addGestureRecognizer(tapGR)
    }
    
    @objc private func didOnPan(_ recognizer: UIPanGestureRecognizer) {
        didPan(recognizer)
        delegate?.didOnPan()
    }
    
    @objc private func didOnTap(_ recognizer: UITapGestureRecognizer) {
        didTap(recognizer)
        delegate?.didOnTap()
    }
}

extension ShapeGesturesControl {
    private func didTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.view)
        self.findSubview(location)
        guard let viewGesture = self.viewGesture else {
            self.view?.hideMenuShape()
            return
        }
        self.view?.bringSubviewToFront(viewGesture)
        viewGesture.showMenuShape()
        self.clearSubview()
    }
}

extension ShapeGesturesControl {
    private func didPan(_ recognizer: UIPanGestureRecognizer) {
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
                self.showMiddleView()
                recognizer.setTranslation(CGPoint.zero, in: viewGesture)
            case .ended, .cancelled:
                self.updateShapeLayerFrameTranslate()
                self.clearSubview()
                self.clearMiddleView()
            default:
                break
        }
    }
    
    private func updateShapeLayerFrameTranslate() {
        guard let viewGesture = self.viewGesture, let view = self.view else {return}
        guard let currLayer = viewGesture.firstSublayer() else {return}
        let newFrame = view.convert(view.bounds, from: viewGesture)
        if type(of: currLayer).isEqual(CAShapeLayer.self) {
            setupShapeLayer(newFrame, currLayer: currLayer as! CAShapeLayer)
        }
        if type(of: currLayer).isEqual(CAGradientLayer.self) {
            setupGradientLayer(newFrame, currLayer: currLayer as! CAGradientLayer)
        }
    }
    
    private func setupShapeLayer(_ newFrame: CGRect, currLayer: CAShapeLayer) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        guard let view = self.view else {return}
        currLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: view.bounds.size)
        currLayer.path = self.shapeLayerPath
        CATransaction.commit()
    }
    
    private func setupGradientLayer(_ newFrame: CGRect, currLayer: CAGradientLayer) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        guard let view = self.view else {return}
        let shapeLayer = currLayer.mask as! CAShapeLayer
        shapeLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: view.bounds.size)
        shapeLayer.path = self.shapeLayerPath
        currLayer.mask = shapeLayer
        CATransaction.commit()
    }
    
    private func findSubview(_ location: CGPoint) {
        guard let view = self.view else {return}
        for subview in view.subviews.reversed() {
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
    
    private func showMiddleView() {
        guard let viewGesture = self.viewGesture, let view = self.view else {return}
        let vert = (viewGesture.center.x > view.frame.midX-1 && viewGesture.center.x < view.frame.midX+1) &&
            (viewGesture.center.y > 0 && viewGesture.center.y < view.frame.maxY)
        let hor = (viewGesture.center.y > view.frame.midY-1 && viewGesture.center.y < view.frame.midY+1) &&
            (viewGesture.center.x > 0 && viewGesture.center.x < view.frame.maxX)
        view.verticalIndicatorView?.toggle(vert)
        view.horizontalIndicatorView?.toggle(hor)
    }
    
    private func clearMiddleView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.view?.verticalIndicatorView?.toggle(false)
            self.view?.horizontalIndicatorView?.toggle(false)
        }
    }
    
    private func clearSubview() {
        self.viewGesture = nil
        self.shapeLayerPath = nil
    }
}
