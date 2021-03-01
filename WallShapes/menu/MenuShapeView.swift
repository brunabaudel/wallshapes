//
//  MenuShapeView.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

protocol MenuShapeViewDelegate {
    func willChangeShape(_ sender: UIButton, type: ShapeType)
    func willDeleteShape(_ sender: UIButton)
    func willApplyGradientShape(_ sender: UIButton)
    func willApplyPlainColorShape(_ sender: UIButton)
    func willApplyShadowShape(_ slider: SliderMenu)
    func willApplyAlphaShape(_ slider: SliderMenu)
    func onSliderValue(_ slider: SliderMenu)
}

class MenuShapeView: UIView {
    var delegate: MenuShapeViewDelegate?
    
    var buttons: [UIButton] = []
    
    var stackView: UIStackView?
    var btnDelete: UIButton?
    var btnCircle: UIButton?
    var btnRectangle: UIButton?
    var btnTriangle: UIButton?
    var btnGradient: UIButton?
    var btnPlainColor: UIButton?
    var btnShadow: UIButton?
    var btnAlpha: UIButton?
    
    var sliderView: SliderMenu?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayout()
        self.initSliderOnWindow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLayout()
        self.initSliderOnWindow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initStackView()
    }
    
    func initLayout() {
        backgroundColor = .init(white: 0.9, alpha: 0.4)
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1
        
        layer.masksToBounds = false
    }
    
    func initStackView() {
        stackView = StackView()
        guard let stackView = self.stackView else {return}
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        initAllButton()
        addSubview(stackView)
        
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.90).isActive = true
        stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95).isActive = true
    }
    
    func initAllButton() {
        initBtnDelete()
        initBtnCircle()
        initBtnRectangle()
        initBtnTriangle()
        initBtnPlainColor()
        initBtnGradient()
        initBtnShadow()
        initBtnAlpha()
    }
    
    func initBtnDelete() {
        btnDelete = UIButton()
        guard let btnDelete = self.btnDelete else {return}
        btnDelete.addTarget(self, action: #selector(deleteShape(_:)), for: .touchUpInside)
        configHighlighted(btnDelete, sfSymbol: "trash", normalColor: .red)
    }
    
    func initBtnCircle() {
        btnCircle = UIButton()
        guard let btnCircle = self.btnCircle else {return}
        btnCircle.addTarget(self, action: #selector(changeShape(_:)), for: .touchUpInside)
        configHighlighted(btnCircle, sfSymbol: "circle.fill")
    }
    
    func initBtnRectangle() {
        btnRectangle = UIButton()
        guard let btnRectangle = self.btnRectangle else {return}
        btnRectangle.addTarget(self, action: #selector(changeShape(_:)), for: .touchUpInside)
        configHighlighted(btnRectangle, sfSymbol: "square.fill")
    }
    
    func initBtnTriangle() {
        btnTriangle = UIButton()
        guard let btnTriangle = self.btnTriangle else {return}
        btnTriangle.addTarget(self, action: #selector(changeShape(_:)), for: .touchUpInside)
        configHighlighted(btnTriangle, sfSymbol: "triangle.fill")
    }
    
    func initBtnGradient() {
        btnGradient = UIButton()
        guard let btnGradient = self.btnGradient else {return}
        btnGradient.addTarget(self, action: #selector(gradientShape(_:)), for: .touchUpInside)
        configHighlighted(btnGradient, sfSymbol: "square")
    }
    
    func initBtnPlainColor() {
        btnPlainColor = UIButton()
        guard let btnPlainColor = self.btnPlainColor else {return}
        btnPlainColor.addTarget(self, action: #selector(plainColorShape(_:)), for: .touchUpInside)
        configHighlighted(btnPlainColor, sfSymbol: "square")
    }
    
    func initBtnShadow() {
        btnShadow = UIButton()
        guard let btnShadow = self.btnShadow else {return}
        btnShadow.addTarget(self, action: #selector(shadowShape(_:)), for: .touchUpInside)
        configSelected(btnShadow, sfSymbol: "shadow")
    }
    
    func initBtnAlpha() {
        btnAlpha = UIButton()
        guard let btnAlpha = self.btnAlpha else {return}
        btnAlpha.addTarget(self, action: #selector(alphaShape(_:)), for: .touchUpInside)
        configSelected(btnAlpha, sfSymbol: "drop.triangle.fill")
    }
    
    func configHighlighted(_ button: UIButton, sfSymbol: String, highlightedColor: UIColor = .lightGray, normalColor: UIColor = .white) {
        let icon = UIImage.configIcon(with: sfSymbol)
        button.setImage(icon?.configIconColor(normalColor), for: .normal)
        button.setImage(icon?.configIconColor(highlightedColor), for: .highlighted)
        stackView?.addArrangedSubview(button)
        buttons.append(button)
    }
    
    func configSelected(_ button: UIButton, sfSymbol: String, selectedColor: UIColor = .lightGray, normalColor: UIColor = .white) {
        let icon = UIImage.configIcon(with: sfSymbol)
        button.setImage(icon?.configIconColor(normalColor), for: .normal)
        button.setImage(icon?.configIconColor(selectedColor), for: .selected)
        stackView?.addArrangedSubview(button)
        buttons.append(button)
    }
    
    func initSliderOnWindow() {
        sliderView = SliderMenu()
        guard let sliderView = self.sliderView else {return}
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.setValue(0.0, animated: true)
        sliderView.isContinuous = true
        sliderView.minimumValue = 0
        sliderView.maximumValue = 1
        sliderView.isHidden = true
        sliderView.addTarget(self, action: #selector(onSliderValueChanged(_:)), for: .valueChanged)

        guard let window = UIApplication.window() else {return}
        window.addSubview(sliderView)

        sliderView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        sliderView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -32).isActive = true
        sliderView.heightAnchor.constraint(equalTo: window.heightAnchor, multiplier: 0.05).isActive = true
        sliderView.widthAnchor.constraint(equalTo: window.widthAnchor, multiplier: 0.6).isActive = true
    }
}

extension MenuShapeView {
    @objc func changeShape(_ sender: UIButton) {
        self.hideSlider()
        self.selectButton(sender)
        switch sender {
            case btnCircle:
                delegate?.willChangeShape(sender, type: ShapeType.circle)
            case btnTriangle:
                delegate?.willChangeShape(sender, type: ShapeType.triangle)
            case btnRectangle:
                delegate?.willChangeShape(sender, type: ShapeType.rectangle)
            default:
                delegate?.willChangeShape(sender, type: ShapeType.circle)
        }
    }
    
    @objc func deleteShape(_ sender: UIButton) {
        self.hideSlider()
        self.selectButton(sender)
        delegate?.willDeleteShape(sender)
    }
    
    @objc func gradientShape(_ sender: UIButton) {
        self.hideSlider()
        self.selectButton(sender)
        delegate?.willApplyGradientShape(sender)
    }
    
    @objc func plainColorShape(_ sender: UIButton) {
        self.hideSlider()
        self.selectButton(sender)
        delegate?.willApplyPlainColorShape(sender)
    }
    
    @objc func shadowShape(_ sender: UIButton) {
        self.selectButton(sender)
        self.showSlider(.shadow)
    }
    
    @objc func alphaShape(_ sender: UIButton) {
        self.selectButton(sender)
        self.showSlider(.alpha)
    }
    
    @objc func onSliderValueChanged(_ sender: SliderMenu) {
        switch sender.type {
            case .shadow:
                delegate?.willApplyShadowShape(sender)
            case .alpha:
                delegate?.willApplyAlphaShape(sender)
            default:
                break
        }
    }
}

extension MenuShapeView {
    func selectButton(_ sender: UIButton) {
        sender.isSelected = true
        for button in buttons {
            if button != sender {
                button.isSelected = false
            }
        }
    }
    
    func showSlider(_ type: SliderType) {
        guard let sliderView = self.sliderView else {return}
        sliderView.isHidden = false
        sliderView.type = type
        delegate?.onSliderValue(sliderView)
    }
    
    func hideSlider() {
        guard let sliderView = self.sliderView else {return}
        sliderView.isHidden = true
        for button in buttons {
            button.isSelected = false
        }
    }
    
    func hideMenu() {
        self.isHidden = true
    }
    
    func showMenu() {
        self.isHidden = false
        if btnShadow!.isSelected {
            self.showSlider(.shadow)
        }
        
        if btnAlpha!.isSelected {
            self.showSlider(.alpha)
        }
    }
}
