//
//  ShapeView.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

protocol ShapeViewDelegate {
    func deleteView(_ shapeView: ShapeView)
}

class ShapeView: UIView {
    internal var delegate: ShapeViewDelegate?
    public var shapeViewControl: ShapeViewControl?
    private var menuShapeView: MenuShapeView?
    
    init(frame: CGRect, menu: MenuShapeView) {
        super.init(frame: frame)
        initShapeView(menu)
        backgroundColor = .clear
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
}

extension ShapeView: MenuShapeViewDelegate {
    func willApplyPlainColorShape(_ sender: UIButton) {
        shapeViewControl?.createPlainColor()
    }
    
    func willDeleteShape(_ sender: UIButton) {
        delegate?.deleteView(self)
    }
    
    func willChangeShape(_ sender: UIButton, type: ShapeType) {
        switch type {
            case ShapeType.circle:
                shapeViewControl?.createPathCircle()
            case ShapeType.rectangle:
                shapeViewControl?.createPathRectangle()
            case ShapeType.triangle:
                shapeViewControl?.createPathTriangle()
            case ShapeType.polygon:
                shapeViewControl?.createPathPolygon()
        }
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
        guard let shapeViewControl = self.shapeViewControl else {return}
        switch slider.type {
            case .shadow:
                slider.setValue(Float(shapeViewControl.shadow()), animated: true)
            case .alpha:
                slider.setValue(Float(shapeViewControl.alpha()), animated: true)
            case .polygon:
                slider.setValue(Float(shapeViewControl.polygon()), animated: true)
            default:
                break
        }
    }
    
    public func showMenuShape() {
        self.menuShapeView?.delegate = self
        self.menuShapeView?.showMenu()
    }
}
