//
//  MenuShapeControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

protocol MenuShapeControlDelegate {
    func onSliderMenu(_ sender: SliderMenu)
    func onMainMenu(_ sender: TypeButton<MenuMainView>)
    func onArrangeMenu(_ sender: TypeButton<ArrangeMenuView>)
}

final class MenuShapeControl {
    internal var delegate: MenuShapeControlDelegate?

    private var sliderView: SliderMenu?
    private var mainMenuView: CustomMenuView<MenuMainView>?
    private var menuArrangeView: CustomMenuView<ArrangeMenuView>?

    init() {
        initSliderOnWindow()
        initMainMenuOnWindow()
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
        sliderView.addTarget(self, action: #selector(onSliderValueChanged(_:)), for: .valueChanged)

        guard let window = UIApplication.window else {return}
        window.addSubview(sliderView)

        sliderView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        sliderView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -32).isActive = true
        sliderView.heightAnchor.constraint(equalTo: window.heightAnchor, multiplier: 0.05).isActive = true
        sliderView.widthAnchor.constraint(equalTo: window.widthAnchor, multiplier: 0.6).isActive = true
    }

    private func initMainMenuOnWindow() {
        mainMenuView = CustomMenuView<MenuMainView>(frame: CGRect.zero)
        guard let mainMenuView = self.mainMenuView else {return}
        mainMenuView.translatesAutoresizingMaskIntoConstraints = false
        mainMenuView.isHidden = true
        mainMenuView.delegate = self

        guard let window = UIApplication.window else {return}
        window.addSubview(mainMenuView)

        let height = (window.frame.width > window.frame.height) ? window.widthAnchor : window.heightAnchor
        let width = (window.frame.width > window.frame.height) ? window.heightAnchor : window.widthAnchor

        mainMenuView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
        mainMenuView.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        mainMenuView.heightAnchor.constraint(equalTo: height, multiplier: 0.5).isActive = true
        mainMenuView.widthAnchor.constraint(equalTo: width, multiplier: 0.1).isActive = true
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
        menuArrangeView.heightAnchor.constraint(equalTo: mainMenuView.heightAnchor, multiplier: 0.5).isActive = true
        menuArrangeView.widthAnchor.constraint(equalTo: mainMenuView.widthAnchor).isActive = true
    }

    public func showMenuShape() {
        mainMenuView?.isHidden = false
    }

    public func hideMenuShape() {
        mainMenuView?.isHidden = true
        menuArrangeView?.isHidden = true
        mainMenuView?.unselectAllButtons()
        menuArrangeView?.unselectAllButtons()
        hideSlider()
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
    }
}

// MARK: - Slider methods

extension MenuShapeControl {
    @objc private func onSliderValueChanged(_ sender: SliderMenu) {
        delegate?.onSliderMenu(sender)
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
}

extension MenuShapeControl: CustomMenuViewDelegate {
    func onClickMenu(_ sender: UIButton) {
        switch sender {
        case is TypeButton<ArrangeMenuView>:
            delegate?.onArrangeMenu(sender as! TypeButton<ArrangeMenuView>)
        case is TypeButton<MenuMainView>:
            delegate?.onMainMenu(sender as! TypeButton<MenuMainView>)
        default:
            NSLog("Error")
        }
    }
}
