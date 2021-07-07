//
//  ShapeGesturesControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class ShapeGesturesControl {
    private weak var view: WallshapeView?
    private var menuShapeControl: MenuShapeControl?
    private var viewGesture: ShapeView?
    private var shapeLayerPath: CGPath?
    private var scale: CGFloat = 0
    private var size: CGSize = CGSize.zero
    private var isLongPress: Bool = false

    private var horizontalIndicatorView: MiddleIndicatorView!
    private var verticalIndicatorView: MiddleIndicatorView!
    private var deleteView: DeleteView!
    private var darkBackgroundDeleteView: DarkBackgroundDeleteView?

    init(_ view: WallshapeView, menuControl: MenuShapeControl) {
        self.view = view
        self.menuShapeControl = menuControl
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

        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(didOnPinch(_:)))
        self.view?.addGestureRecognizer(pinchGR)

        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(didOnLongPress(_:)))
        longPressGR.delegate = self.view
        longPressGR.minimumPressDuration = 0.4
        self.view?.addGestureRecognizer(longPressGR)
    }

    @objc private func didOnPan(_ recognizer: UIPanGestureRecognizer) {
        didPan(recognizer)
    }

    @objc private func didOnSingleTap(_ recognizer: UITapGestureRecognizer) {
        didSingleTap(recognizer)
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
        switch recognizer.state {
        case .began:
            let location = recognizer.location(in: self.view)
            self.findSubview(location)
            guard let view = self.view, let tempview = view.tempView else {return}
            self.size = tempview.frame.size
        case .changed:
            guard let view = self.view, let tempview = view.tempView else {return}
            self.scale = recognizer.scale
            let newSize = tempview.bounds.applying(tempview.transform.scaledBy(x: self.scale, y: self.scale))
            if newSize.size.height > 10 {
                tempview.bounds = newSize
                self.updateShapeLayerFrameScale()
            }
            recognizer.scale = 1
        case .ended, .cancelled:
            guard let view = self.view, let tempview = view.tempView,
                  let viewGesture = self.viewGesture else {return}
            viewGesture.frame = tempview.bounds
            self.clearSubview()
        default:
            break
        }
    }

    private func updateShapeLayerFrameScale() {
        guard let view = self.view,
              let tempview = view.tempView,
              let viewGesture = self.viewGesture,
              let currLayer = viewGesture.firstSublayer else {return}
        let newFrame = view.convert(view.bounds, from: tempview)
        if let shplayer = currLayer as? CAShapeLayer {
            setupShapeLayerScale(newFrame, currLayer: shplayer)
            return
        }
        if let gradlayer = currLayer as? CAGradientLayer {
            setupGradientLayerScale(newFrame, currLayer: gradlayer)
        }
    }

    private func setupShapeLayerScale(_ newFrame: CGRect, currLayer: CAShapeLayer) {
        guard let view = self.view, let tempview = view.tempView else {return}
        CATransaction.removeAnimation {
            guard let scaledPath = self.shapeLayerPath?.scale(self.size, toSize: tempview.frame.size) else {return}
            let frameLayer = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: tempview.frame.size)
            currLayer.path = scaledPath
            currLayer.frame = frameLayer
            setupSelectedBorderLayerScale(frameLayer, scaledPath: scaledPath)
        }
    }

    private func setupGradientLayerScale(_ newFrame: CGRect, currLayer: CAGradientLayer) {
        guard let view = self.view, let tempview = view.tempView else {return}
        CATransaction.removeAnimation {
            guard let shapeLayer = currLayer.mask as? CAShapeLayer,
                  let scaledPath = self.shapeLayerPath?.scale(self.size, toSize: tempview.frame.size) else {return}
            let frameLayer = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: tempview.frame.size)
            shapeLayer.path = scaledPath
            shapeLayer.frame = frameLayer
            currLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: tempview.frame.size)
            currLayer.mask = shapeLayer
            setupSelectedBorderLayerScale(frameLayer, scaledPath: scaledPath)
        }
    }
    
    private func setupSelectedBorderLayerScale(_ newFrame: CGRect, scaledPath: CGPath) {
        guard let view = self.view, let selectBorder = view.selectBorder,
              let borderLayer = selectBorder.firstSublayer as? CAShapeLayer else {return}
        borderLayer.path = scaledPath
        borderLayer.frame = newFrame
    }
}

extension ShapeGesturesControl {
    private func didSingleTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.view)
        self.findSubview(location)
        guard let viewGesture = self.viewGesture else {
            menuShapeControl?.hideMenu()
            menuShapeControl?.unselectShapeView()
            return
        }
        menuShapeControl?.setupSliderMenuShape(viewGesture)
        menuShapeControl?.showMenu()
        self.clearSubview()
    }
}

extension ShapeGesturesControl {
    private func didPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            menuShapeControl?.hideMenu()
            let location = recognizer.location(in: self.view)
            self.findSubview(location)
        case .changed:
            if !self.isLongPress {self.showMiddleIndicators()}
            guard let _ = self.viewGesture, let view = self.view, let tempview = view.tempView else {return}
            if self.isLongPress { self.hoverDeleteView() }
            var translation = recognizer.translation(in: tempview)
            translation = translation.applying(tempview.transform)
            tempview.center.x += translation.x
            tempview.center.y += translation.y
            self.shapeLayerPath = self.shapeLayerPath?.translate(translation)
            recognizer.setTranslation(CGPoint.zero, in: tempview)
        case .ended, .cancelled:
            self.updateShapeLayerFrameTranslate()
            self.clearMiddleIndicators()
            if !isLongPress {
                guard let viewGesture = self.viewGesture else {return}
                menuShapeControl?.setupSliderMenuShape(viewGesture)
                menuShapeControl?.showMenu()
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
        if let shplayer = currLayer as? CAShapeLayer {
            setupShapeLayer(newFrame, currLayer: shplayer)
            return
        }
        if let gradlayer = currLayer as? CAGradientLayer {
            setupGradientLayer(newFrame, currLayer: gradlayer)
        }
    }

    private func setupShapeLayer(_ newFrame: CGRect, currLayer: CAShapeLayer) {
        CATransaction.removeAnimation {
            currLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: newFrame.size)
            currLayer.path = self.shapeLayerPath
        }
    }

    private func setupGradientLayer(_ newFrame: CGRect, currLayer: CAGradientLayer) {
        CATransaction.removeAnimation {
            guard let shapeLayer = currLayer.mask as? CAShapeLayer else {return}
            shapeLayer.frame = CGRect(origin: CGPoint(x: -newFrame.minX, y: -newFrame.minY), size: newFrame.size)
            shapeLayer.path = self.shapeLayerPath
            currLayer.mask = shapeLayer
        }
    }
}
    
extension ShapeGesturesControl {
    private func findSubview(_ location: CGPoint) {
        guard let view = self.view, let tempView = view.tempView else {return}
        for subview in view.subviews.reversed() {
            if let subview = subview as? ShapeView {
                guard let currLayer = subview.firstSublayer else {return}
                if currLayer.contains(location) {
                    self.viewGesture = subview
                    self.shapeLayerPath = currLayer.layerMutableCopy
                    self.menuShapeControl?.unselectShapeView()
                    self.menuShapeControl?.selectShapeView(subview)
                    break
                }
            } else {
                if tempView.frame.contains(location) {
                    let subview = (tempView.subviews.filter {type(of: $0) == ShapeView.self}).first
                    if let subview = subview as? ShapeView {
                        guard let currLayer = subview.firstSublayer else {return}
                        if currLayer.contains(location) {
                            self.viewGesture = subview
                            self.shapeLayerPath = currLayer.layerMutableCopy
                            break
                        }
                    }
                }
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
        if recognizer.state == .began {
            self.isLongPress = true
            let location = recognizer.location(in: self.view)
            self.findSubview(location)
            self.setupLongPress()
            self.hoverDeleteView()
        }

        if recognizer.state == .ended || recognizer.state == .cancelled ||
            recognizer.state == .failed || recognizer.state == .possible {
            if self.viewGesture != nil {
                self.resetLongPress()
                return
            }
            self.deleteViewGesture()
            self.resetLongPress()
            self.isLongPress = false
        }
    }

    private func setupLongPress() {
        if self.viewGesture != nil {
            menuShapeControl?.hideMenu()
            self.insertDarkDeleteView()
            self.deleteView.toggle(true)
        }
    }

    private func resetLongPress() {
        menuShapeControl?.hideMenu()
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

// MARK: - Middle Indicators

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
        guard let view = self.view, let temview = view.tempView else {return}
        let vert = (temview.center.x > view.frame.midX-1 && temview.center.x < view.frame.midX+1) &&
            (temview.center.y > 0 && temview.center.y < view.frame.maxY)
        let hor = (temview.center.y > view.frame.midY-1 && temview.center.y < view.frame.midY+1) &&
            (temview.center.x > 0 && temview.center.x < view.frame.maxX)
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

// MARK: - Delete

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
