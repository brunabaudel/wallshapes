//
//  ShapeGesturesControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

class ShapeGesturesControl {
    private weak var view: WallshapeView? //TODO: change to UIView and change the onTap function
    private var viewGesture: ShapeView?
    private var shapeLayerPath: CGPath?
    private var scale: CGFloat = 0
    private var size: CGSize = CGSize.zero
    private var isLongPress: Bool = false
    
    private var horizontalIndicatorView: MiddleIndicatorView!
    private var verticalIndicatorView: MiddleIndicatorView!
    private var deleteView: DeleteView!
    private var darkBackgroundDeleteView: DarkBackgroundDeleteView?
    
    init<T: WallshapeView>(_ view: T) {
        self.view = view
        initMiddleIndicators()
        initDeleteView()
        initGestures()
    }
}

extension ShapeGesturesControl {
    private func initGestures() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didOnPan(_:)))
        panGR.delegate = self.view
        self.view?.addGestureRecognizer(panGR)
        
        let singleTapGR = UITapGestureRecognizer(target: self, action: #selector(didOnSingleTap(_:)))
        singleTapGR.numberOfTapsRequired = 1
        self.view?.addGestureRecognizer(singleTapGR)
        
        let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(didOnDoubleTap(_:)))
        doubleTapGR.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(doubleTapGR)
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(didOnPinch(_:)))
        self.view?.addGestureRecognizer(pinchGR)
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(didOnLongPress(_:)))
        longPressGR.delegate = self.view
        longPressGR.minimumPressDuration = 1
        self.view?.addGestureRecognizer(longPressGR)
    }
    
    @objc private func didOnPan(_ recognizer: UIPanGestureRecognizer) {
        didPan(recognizer)
    }
    
    @objc private func didOnSingleTap(_ recognizer: UITapGestureRecognizer) {
        didSingleTap(recognizer)
    }
    
    @objc private func didOnDoubleTap(_ recognizer: UITapGestureRecognizer) {
        didDoubleTap(recognizer)
    }
    
    @objc private func didOnPinch(_ recognizer: UIPinchGestureRecognizer) {
        didPinch(recognizer)
    }
    
    @objc private func didOnLongPress(_ recognizer: UILongPressGestureRecognizer) {
        didLongPress(recognizer)
    }
}

extension ShapeGesturesControl {
    private func didPinch(_ recognizer: UIPinchGestureRecognizer) {
        switch (recognizer.state) {
            case .began:
                let location = recognizer.location(in: self.view)
                self.findSubview(location)
                guard let viewGesture = self.viewGesture else {return}
                self.size = viewGesture.frame.size
            case .changed:
                guard let viewGesture = self.viewGesture else {return}
                self.scale = recognizer.scale
                viewGesture.bounds = viewGesture.bounds
                                        .applying(viewGesture.transform.scaledBy(x: self.scale, y: self.scale))
                self.updateShapeLayerFrameScale()
                recognizer.scale = 1
            case .ended, .cancelled:
                self.clearSubview()
            default:
                break
        }
    }
    
    private func updateShapeLayerFrameScale() {
        guard let viewGesture = self.viewGesture, let view = self.view else {return}
        guard let currLayer = viewGesture.firstSublayer else {return}
        let newFrame = view.convert(view.bounds, from: viewGesture)
        if currLayer.isEqualTo(type: CAShapeLayer.self) {
            setupShapeLayerScale(newFrame, currLayer: currLayer as! CAShapeLayer)
        }
        if currLayer.isEqualTo(type: CAGradientLayer.self) {
            setupGradientLayerScale(newFrame, currLayer: currLayer as! CAGradientLayer)
        }
    }
    
    private func setupShapeLayerScale(_ newFrame: CGRect, currLayer: CAShapeLayer) {
        guard let viewGesture = self.viewGesture else {return}
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        currLayer.path = self.shapeLayerPath?.scale(self.size, toSize: viewGesture.frame.size)
        currLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: viewGesture.frame.size)
        CATransaction.commit()
    }
    
    private func setupGradientLayerScale(_ newFrame: CGRect, currLayer: CAGradientLayer) {
        guard let viewGesture = self.viewGesture else {return}
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let shapeLayer = currLayer.mask as! CAShapeLayer
        shapeLayer.path = self.shapeLayerPath?.scale(self.size, toSize: viewGesture.frame.size)
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
            case .changed:
                if !self.isLongPress { self.showMiddleIndicators() }
                guard let viewGesture = self.viewGesture else {return}
                if self.isLongPress { self.hoverDeleteView() }
                var translation = recognizer.translation(in: viewGesture)
                translation = translation.applying(viewGesture.transform)
                viewGesture.center.x += translation.x
                viewGesture.center.y += translation.y
                self.shapeLayerPath = self.shapeLayerPath?.translate(translation)
                recognizer.setTranslation(CGPoint.zero, in: viewGesture)
            case .ended, .cancelled:
                self.updateShapeLayerFrameTranslate()
                self.clearMiddleIndicators()
                if !isLongPress {
                    guard let viewGesture = self.viewGesture else {return}
                    viewGesture.showMenuShape()
                    self.clearSubview()
                }
            default:
                break
        }
    }
    
    private func updateShapeLayerFrameTranslate() {
        guard let viewGesture = self.viewGesture, let view = self.view else {return}
        guard let currLayer = viewGesture.firstSublayer else {return}
        let newFrame = view.convert(view.bounds, from: viewGesture)
        if currLayer.isEqualTo(type: CAShapeLayer.self) {
            setupShapeLayer(newFrame, currLayer: currLayer as! CAShapeLayer)
        }
        if currLayer.isEqualTo(type: CAGradientLayer.self) {
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
        guard let view = self.view else { return }
        for subview in view.subviews.reversed() {
            guard let currLayer = subview.firstSublayer else { return }
            if currLayer.contains(location) {
                self.viewGesture = subview as? ShapeView
                self.shapeLayerPath = currLayer.layerMutableCopy
                break
            }
        }
    }
    
    private func clearSubview() {
        self.viewGesture = nil
        self.shapeLayerPath = nil
        self.scale = 0
        self.size = CGSize.zero
    }
}

extension ShapeGesturesControl {
    private func didLongPress(_ recognizer: UILongPressGestureRecognizer) {
        switch (recognizer.state) {
            case .began:
                self.isLongPress = true
                let location = recognizer.location(in: self.view)
                self.findSubview(location)
                self.setupLongPress()
            case .changed:
                NSLog("changed")
            case .ended, .cancelled, .failed, .possible:
                guard let _ = self.viewGesture else {
                    self.resetLongPress()
                    return
                }
                self.deleteViewGesture()
                self.resetLongPress()
                self.isLongPress = false
            @unknown default:
                self.resetLongPress()
                self.isLongPress = false
        }
    }
    
    private func setupLongPress() {
        guard let _ = self.viewGesture else {return}
        self.view?.hideMenuShape()
        self.insertDarkDeleteView()
        self.deleteView.toggle(true)
    }
    
    private func resetLongPress() {
        self.view?.hideMenuShape()
        self.removeDarkDeleteView()
        self.deleteView.toggle(false)
        self.deleteView.hover(false)
    }
    
    private func deleteViewGesture() {
        guard let viewGesture = self.viewGesture else {return}
        if viewGesture.frame.intersects(deleteView.frame) {
            self.viewGesture = nil
            viewGesture.fadeOut(0.3) { _ in
                viewGesture.removeFromSuperview()
            }
        }
    }
    
    private func hoverDeleteView() {
        guard let viewGesture = self.viewGesture else {return}
        if viewGesture.frame.intersects(deleteView.frame) {
            deleteView.hover(true)
        } else {
            deleteView.hover(false)
        }
    }
}

//MARK: - Middle Indicators

extension ShapeGesturesControl {
    private func initMiddleIndicators() {
        guard let window = UIApplication.window else { return }
        self.verticalIndicatorView = MiddleIndicatorView(
            frame: CGRect(x: window.frame.midX, y: window.frame.minY, width: 10, height: window.frame.height),
            type: MiddleIndicatorViewType.vertical)
        
        self.horizontalIndicatorView = MiddleIndicatorView(
            frame: CGRect(x: window.frame.minX, y: window.frame.midY, width: window.frame.width, height: 10),
            type: MiddleIndicatorViewType.horizontal)
        
        window.addSubview(verticalIndicatorView)
        window.addSubview(horizontalIndicatorView)
    }
    
    private func showMiddleIndicators() {
        guard let viewGesture = self.viewGesture, let view = self.view else {return}
        let vert = (viewGesture.center.x > view.frame.midX-1 && viewGesture.center.x < view.frame.midX+1) &&
            (viewGesture.center.y > 0 && viewGesture.center.y < view.frame.maxY)
        let hor = (viewGesture.center.y > view.frame.midY-1 && viewGesture.center.y < view.frame.midY+1) &&
            (viewGesture.center.x > 0 && viewGesture.center.x < view.frame.maxX)
        self.verticalIndicatorView?.toggle(vert)
        self.horizontalIndicatorView?.toggle(hor)
    }
    
    private func clearMiddleIndicators() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.verticalIndicatorView?.toggle(false)
            self.horizontalIndicatorView?.toggle(false)
        }
    }
}

//MARK: - Delete

extension ShapeGesturesControl {
    private func initDeleteView() {
        guard let window = UIApplication.window else { return }
        self.deleteView = DeleteView(frame: CGRect(x: window.frame.midX - 25, y: window.frame.maxY - 100,
                                                   width: 45, height: 45))
        self.darkBackgroundDeleteView = DarkBackgroundDeleteView(frame: window.frame)
        window.addSubview(self.deleteView)
    }
    
    private func insertDarkDeleteView() {
        guard let view = self.view, let viewGesture = self.viewGesture,
              let darkBackgroundDeleteView = self.darkBackgroundDeleteView,
              let viewGestureIndex = view.subviews.firstIndex(of: viewGesture) else { return }
        darkBackgroundDeleteView.index = viewGestureIndex
        view.bringSubviewToFront(viewGesture)
        view.insertSubview(darkBackgroundDeleteView, belowSubview: viewGesture)
        darkBackgroundDeleteView.toggle(true)
    }
    
    private func removeDarkDeleteView() {
        guard let view = self.view,
              let darkBackgroundDeleteView = self.darkBackgroundDeleteView else { return }
        darkBackgroundDeleteView.toggle(false) { _ in
            if let viewGesture = self.viewGesture {
                view.insertSubview(viewGesture, at: darkBackgroundDeleteView.index)
            }
            darkBackgroundDeleteView.removeFromSuperview()
        }
    }
}
