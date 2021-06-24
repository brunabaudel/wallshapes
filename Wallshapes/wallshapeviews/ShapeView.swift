//
//  ShapeView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

protocol ShapeViewDelegate: AnyObject {
    func mainView(_ shapeView: ShapeView, _ sender: TypeButton<MainMenuView>)
    func shapeView(_ shapeView: ShapeView, _ sender: TypeButton<ShapeMenuView>)
    func arrangeView(_ shapeView: ShapeView, _ sender: TypeButton<ArrangeMenuView>)
    func sliderView(_ shapeView: ShapeView, _ sender: SliderMenu)
}

final class ShapeView: UIView {
    internal weak var delegate: ShapeViewDelegate?
    private(set) var shapeViewControl: ShapeViewControl?
    private var menuShapeControl: MenuShapeControl?

    init(frame: CGRect, menu: MenuShapeControl, shape: Shape) {
        super.init(frame: frame)
        self.shapeViewControl = ShapeViewControl(self, shape: shape)
        self.menuShapeControl = menu
        self.menuShapeControl?.delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension ShapeView {
    public func setupSliderMenuShape() {
        guard let type = menuShapeControl?.typeSlider() else {return}
        switch type {
        case .shadow:
            menuShapeControl?.setupSlider(value: Float(shapeViewControl?.shape?.shadowRadius ?? 0))
        case .alpha:
            menuShapeControl?.setupSlider(value: Float(shapeViewControl?.shape?.alpha ?? 1))
        case .polygon:
            menuShapeControl?.setupSlider(value: Float(shapeViewControl?.shape?.polygon ?? 0))
        }
    }
}

extension ShapeView: MenuShapeControlDelegate {
    func onMainMenu(_ sender: TypeButton<MainMenuView>) {
        delegate?.mainView(self, sender)
    }
    
    func onShapeMenu(_ sender: TypeButton<ShapeMenuView>) {
        delegate?.shapeView(self, sender)
    }

    func onArrangeMenu(_ sender: TypeButton<ArrangeMenuView>) {
        delegate?.arrangeView(self, sender)
    }

    func onSliderMenu(_ slider: SliderMenu) {
        delegate?.sliderView(self, slider)
    }
}
