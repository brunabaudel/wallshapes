//
//  MenuShapeControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

protocol MenuShapeControlDelegate: AnyObject {
    func onSliderMenu(_ sender: SliderMenu, shapeView: ShapeView)
    func onMainMenu(_ sender: TypeButton<MainMenuView>, shapeView: ShapeView)
    func onArrangeMenu(_ sender: TypeButton<ArrangeMenuView>, shapeView: ShapeView)
    func onShapeMenu(_ sender: TypeButton<ShapeMenuView>, shapeView: ShapeView)
}

final class MenuShapeControl {
    internal weak var delegate: MenuShapeControlDelegate?

    private weak var shapeview: ShapeView?
    private(set) weak var wallshapeview: WallshapeView?

    private var sliderView: SliderMenu?
    private var mainMenuView: CustomMenuView<MainMenuView>?
    private var shapeMenuView: CustomMenuView<ShapeMenuView>?
    private var menuArrangeView: CustomMenuView<ArrangeMenuView>?
    private var shapeViewControl: ShapeViewControl?

    init(_ wallshapeview: WallshapeView) {
        self.wallshapeview = wallshapeview
        self.shapeViewControl = ShapeViewControl(self)
        initSliderOnWindow()
        initMainMenuOnWindow()
        initShapeMenuOnWindow()
        initArrangeMenuOnWindow()
    }

    private func initSliderOnWindow() {
        sliderView = SliderMenu()
        guard let sliderView = self.sliderView else {return}
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.setValue(0.0, animated: true)
        sliderView.isContinuous = true
        sliderView.minimumValue = 0
        sliderView.maximumValue = 1
        sliderView.isHidden = true
        sliderView.addTarget(self, action: #selector(onSliderValueChanged(_:_:)), for: .valueChanged)

        guard let window = UIApplication.window else {return}
        window.addSubview(sliderView)

        sliderView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        sliderView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -32).isActive = true
        sliderView.heightAnchor.constraint(equalTo: window.heightAnchor, multiplier: 0.05).isActive = true
        sliderView.widthAnchor.constraint(equalTo: window.widthAnchor, multiplier: 0.6).isActive = true
    }

    private func initMainMenuOnWindow() {
        mainMenuView = CustomMenuView<MainMenuView>(frame: CGRect.zero)
        guard let mainMenuView = self.mainMenuView else {return}
        mainMenuView.translatesAutoresizingMaskIntoConstraints = false
        mainMenuView.isHidden = true
        mainMenuView.delegate = self

        guard let window = UIApplication.window else {return}
        window.addSubview(mainMenuView)

        mainMenuView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
        mainMenuView.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        mainMenuView.heightAnchor.constraint(equalTo: window.heightAnchor, multiplier: 0.65).isActive = true
        mainMenuView.widthAnchor.constraint(equalTo: window.heightAnchor, multiplier: 0.075).isActive = true
    }

    private func initArrangeMenuOnWindow() {
        menuArrangeView = CustomMenuView<ArrangeMenuView>(frame: CGRect.zero)
        guard let menuArrangeView = self.menuArrangeView, let mainMenuView = self.mainMenuView else {return}
        menuArrangeView.translatesAutoresizingMaskIntoConstraints = false
        menuArrangeView.isHidden = true
        menuArrangeView.delegate = self

        guard let window = UIApplication.window else {return}
        window.addSubview(menuArrangeView)

        menuArrangeView.trailingAnchor.constraint(equalTo: mainMenuView.leadingAnchor, constant: -4).isActive = true
        menuArrangeView.centerYAnchor.constraint(equalTo: mainMenuView.centerYAnchor).isActive = true
        menuArrangeView.heightAnchor.constraint(equalTo: mainMenuView.heightAnchor, multiplier: 0.6).isActive = true
        menuArrangeView.widthAnchor.constraint(equalTo: mainMenuView.widthAnchor).isActive = true
    }

    private func initShapeMenuOnWindow() {
        shapeMenuView = CustomMenuView<ShapeMenuView>(frame: CGRect.zero)
        guard let shapeMenuView = self.shapeMenuView, let mainMenuView = self.mainMenuView else {return}
        shapeMenuView.translatesAutoresizingMaskIntoConstraints = false
        shapeMenuView.isHidden = true
        shapeMenuView.delegate = self

        guard let window = UIApplication.window else {return}
        window.addSubview(shapeMenuView)

        shapeMenuView.trailingAnchor.constraint(equalTo: mainMenuView.leadingAnchor, constant: -4).isActive = true
        shapeMenuView.centerYAnchor.constraint(equalTo: mainMenuView.centerYAnchor).isActive = true
        shapeMenuView.heightAnchor.constraint(equalTo: mainMenuView.heightAnchor, multiplier: 0.6).isActive = true
        shapeMenuView.widthAnchor.constraint(equalTo: mainMenuView.widthAnchor).isActive = true
    }

    public func showMenu() {
        mainMenuView?.isHidden = false
    }

    public func hideMenu() {
        CATransaction.removeAnimation {
            mainMenuView?.isHidden = true
            shapeMenuView?.isHidden = true
            menuArrangeView?.isHidden = true
            mainMenuView?.unselectAllButtons()
            shapeMenuView?.unselectAllButtons()
            menuArrangeView?.unselectAllButtons()
            hideSlider()
        }
    }
}

// MARK: - Shape methods

extension MenuShapeControl {
    public func showShapeMenu() {
        guard let shapeMenuView = self.shapeMenuView else {return}
        shapeMenuView.isHidden = !shapeMenuView.isHidden
    }

    func hideShapeMenu() {
        guard let shapeMenuView = self.shapeMenuView else {return}
        shapeMenuView.isHidden = true
        shapeMenuView.unselectAllButtons()
    }
}

// MARK: - Arrange methods

extension MenuShapeControl {
    public func showArrangeMenu() {
        guard let menuArrangeView = self.menuArrangeView else {return}
        menuArrangeView.isHidden = !menuArrangeView.isHidden
    }

    func hideMenuArrange() {
        guard let menuArrangeView = self.menuArrangeView else {return}
        menuArrangeView.isHidden = true
        menuArrangeView.unselectAllButtons()
    }
}

// MARK: - Slider methods

extension MenuShapeControl {
    @objc private func onSliderValueChanged(_ sender: SliderMenu, _ event: UIEvent) {
        guard let shapeview = self.shapeview, let view = wallshapeview,
              let selectBorder = view.selectBorder else {return}
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                selectBorder.isHidden = true
                self.hideMenuSlider()
            case .moved:
                delegate?.onSliderMenu(sender, shapeView: shapeview)
            case .ended:
                selectBorder.isHidden = false
                self.showMenuSlider()
            default:
                NSLog("Error")
            }
        }
    }

    public func selectSlider(_ type: SliderType, value: Float, _ isSelected: Bool) {
        if !isSelected {
            showSlider(type, value: value)
        } else {
            hideSlider()
        }
    }

    private func showSlider(_ type: SliderType, value: Float) {
        guard let sliderView = self.sliderView else {return}
        sliderView.isHidden = false
        sliderView.type = type
        sliderView.setValue(value, animated: true)
    }

    public func hideSlider() {
        guard let sliderView = self.sliderView else {return}
        sliderView.isHidden = true
        sliderView.type = nil
    }

    public func typeSlider() -> SliderType? {
        return sliderView?.type
    }

    public func setupSlider(value: Float) {
        guard let sliderView = self.sliderView else {return}
        sliderView.setValue(value, animated: true)
    }

    public func hideMenuSlider() {
        mainMenuView?.isHidden = true
        shapeMenuView?.isHidden = true
    }

    public func showMenuSlider() {
        mainMenuView?.isHidden = false
        if sliderView?.type == .polygon {
            guard let shapeMenuView = self.shapeMenuView else {return}
            shapeMenuView.isHidden = false
        }
    }
}

extension MenuShapeControl: CustomMenuViewDelegate {
    func onClickMenu(_ sender: UIButton) {
        guard let shapeview = self.shapeview else {return}
        switch sender {
        case is TypeButton<ArrangeMenuView>:
            guard let sender = sender as? TypeButton<ArrangeMenuView> else {return}
            delegate?.onArrangeMenu(sender, shapeView: shapeview)
        case is TypeButton<ShapeMenuView>:
            guard let sender = sender as? TypeButton<ShapeMenuView> else {return}
            delegate?.onShapeMenu(sender, shapeView: shapeview)
        case is TypeButton<MainMenuView>:
            guard let sender = sender as? TypeButton<MainMenuView> else {return}
            delegate?.onMainMenu(sender, shapeView: shapeview)
        default:
            NSLog("Error")
        }
    }
}

extension MenuShapeControl {
    public func createShapeView(_ shapeview: ShapeView) {
        shapeViewControl?.createShapeView(shapeview)
    }

    public func setupSliderMenuShape(_ shapeview: ShapeView) {
        shapeViewControl?.setupSliderMenuShape(shapeview)
    }

    public func selectShapeView(_ shapeview: ShapeView) {
        self.shapeview = shapeview
        shapeViewControl?.selectView(shapeview)
    }

    public func unselectShapeView() {
        shapeViewControl?.unselectView()
    }
}
