//
//  ShapeView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

protocol ShapeViewDelegate {
    func deleteView(_ shapeView: ShapeView)
}

class ShapeView: UIView {
    internal var delegate: ShapeViewDelegate?
    private(set) var shapeViewControl: ShapeViewControl?
    private var menuShapeView: MenuShapeView?
    
    //Load shape
    init(frame: CGRect, menu: MenuShapeView, shape: Shape) {
        super.init(frame: frame)
        initLoadShapeView(menu, shape: shape)
    }
    
    //Add shape
    init(frame: CGRect, menu: MenuShapeView) {
        super.init(frame: frame)
        initShapeView(menu)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initShapeView(_ menu: MenuShapeView) {
        shapeViewControl = ShapeViewControl(self)
        menuShapeView = menu
        menuShapeView?.delegate = self
        backgroundColor = .clear
    }
    
    private func initLoadShapeView(_ menu: MenuShapeView, shape: Shape) {
        shapeViewControl = ShapeViewControl(self, shape: shape)
        menuShapeView = menu
        menuShapeView?.delegate = self
        backgroundColor = .clear
    }
}

extension ShapeView: MenuShapeViewDelegate {
    func willApplyPlainColorShape(_ sender: UIButton) {
        shapeViewControl?.createPlainColor()
    }
    
    func willDeleteShape(_ sender: UIButton) {
        delegate?.deleteView(self)
    }
    
    func willChangeShape(_ sender: UIButton, type: ShapeType) {
        shapeViewControl?.createPath(by: type)
    }
    
    func willApplyGradientShape(_ sender: UIButton) {
        shapeViewControl?.createGradientColors()
    }
    
    func willApplyShadowShape(_ sender: SliderMenu) {
        let value = CGFloat(sender.value)
        shapeViewControl?.createShadow(value)
    }
    
    func willApplyAlphaShape(_ sender: SliderMenu) {
        let value = CGFloat(sender.value)
        shapeViewControl?.createAlpha(value)
    }
    
    func willApplyPolygonShape(_ sender: SliderMenu) {
        let value = CGFloat(sender.value)
        shapeViewControl?.createPolygon(value)
    }
    
    func onSliderValue(_ slider: SliderMenu) {
        shapeViewControl?.changeSliderValue(slider)
    }
    
    public func showMenuShape() {
        menuShapeView?.delegate = self
        menuShapeView?.showMenu()
    }
}
