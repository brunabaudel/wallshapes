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
    func didOnPinch()
}

class ShapeGesturesControl {
    internal var delegate: ShapeGesturesControlDelegate?
    
    private weak var view: RandomGradientView? //TODO: change to UIView and change the onTap function
    private var viewGesture: ShapeView?
    private var shapeLayerPath: CGPath?
    private var scale: CGFloat = 0
    
    init<T: RandomGradientView>(_ view: T) {
        self.view = view
        initGestures()
    }
}

extension ShapeGesturesControl {
    private func initGestures() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didOnPan(_:)))
        self.view?.addGestureRecognizer(panGR)
        
        let singleTapGR = UITapGestureRecognizer(target: self, action: #selector(didOnSingleTap(_:)))
        singleTapGR.numberOfTapsRequired = 1
        self.view?.addGestureRecognizer(singleTapGR)
        
        let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(didOnDoubleTap(_:)))
        doubleTapGR.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(doubleTapGR)
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(didOnPinch(_:)))
        self.view?.addGestureRecognizer(pinchGR)
    }
    
    @objc private func didOnPan(_ recognizer: UIPanGestureRecognizer) {
        didPan(recognizer)
        delegate?.didOnPan()
    }
    
    @objc private func didOnSingleTap(_ recognizer: UITapGestureRecognizer) {
        didSingleTap(recognizer)
        delegate?.didOnTap()
    }
    
    @objc private func didOnDoubleTap(_ recognizer: UITapGestureRecognizer) {
        didDoubleTap(recognizer)
        delegate?.didOnTap()
    }
    
    @objc private func didOnPinch(_ recognizer: UIPinchGestureRecognizer) {
        didPinch(recognizer)
        delegate?.didOnPinch()
    }
}

extension ShapeGesturesControl {
    private func didPinch(_ recognizer: UIPinchGestureRecognizer) {
        switch (recognizer.state) {
            case .began:
                let location = recognizer.location(in: self.view)
                self.findSubview(location)
//                self.viewGesture?.showMenuShape() //TODO hide menu
            case .changed:
                guard let viewGesture = self.viewGesture else {return}
                self.scale = recognizer.scale
                viewGesture.bounds = viewGesture.bounds.applying(viewGesture.transform.scaledBy(x: self.scale, y: self.scale))
                self.updateShapeLayerFrameScale()
                recognizer.scale = 1
            case .ended, .cancelled:
                guard let viewGesture = self.viewGesture else {return}
                viewGesture.shapeViewControl?.shapeSize(size: viewGesture.frame.size)
                self.clearSubview()
                self.scale = 0
            default:
                break
        }
    }
    
    private func updateShapeLayerFrameScale() {
        guard let viewGesture = self.viewGesture, let view = self.view else {return}
        guard let currLayer = viewGesture.firstSublayer() else {return}
        let newFrame = view.convert(view.bounds, from: viewGesture)
        if type(of: currLayer).isEqual(CAShapeLayer.self) {
            setupShapeLayerScale(newFrame, currLayer: currLayer as! CAShapeLayer)
        }
        if type(of: currLayer).isEqual(CAGradientLayer.self) {
            setupGradientLayerScale(newFrame, currLayer: currLayer as! CAGradientLayer)
        }
    }
    
    private func setupShapeLayerScale(_ newFrame: CGRect, currLayer: CAShapeLayer) {
        guard let viewGesture = self.viewGesture, let shapeViewControl = viewGesture.shapeViewControl else {return}
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        currLayer.path = self.shapeLayerPath?.scale(shapeViewControl.shapeSize(), toSize: viewGesture.frame.size)
        currLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: viewGesture.frame.size)
        CATransaction.commit()
    }
    
    private func setupGradientLayerScale(_ newFrame: CGRect, currLayer: CAGradientLayer) {
        guard let viewGesture = self.viewGesture, let shapeViewControl = viewGesture.shapeViewControl else {return}
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let shapeLayer = currLayer.mask as! CAShapeLayer
        shapeLayer.path = self.shapeLayerPath?.scale(shapeViewControl.shapeSize(), toSize: viewGesture.frame.size)
        shapeLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: viewGesture.frame.size)
        currLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: viewGesture.frame.size)
        currLayer.mask = shapeLayer
        CATransaction.commit()
    }
}

extension ShapeGesturesControl {
    private func didSingleTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.view)
        self.findSubview(location)
        guard let viewGesture = self.viewGesture else {
            self.view?.hideMenuShape()
            return
        }
        viewGesture.showMenuShape()
        self.clearSubview()
    }
    
    private func didDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.view)
        self.findSubview(location)
        guard let viewGesture = self.viewGesture else {
            self.view?.hideMenuShape()
            return
        }
        viewGesture.showMenuShape()
        self.view?.bringSubviewToFront(viewGesture)
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
                self.showMiddleView()
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
        currLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: newFrame.size)
        currLayer.path = self.shapeLayerPath
        CATransaction.commit()
    }
    
    private func setupGradientLayer(_ newFrame: CGRect, currLayer: CAGradientLayer) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let shapeLayer = currLayer.mask as! CAShapeLayer
        shapeLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: newFrame.size)
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
