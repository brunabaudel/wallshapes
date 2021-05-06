//
//  MenuShapeView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

protocol MenuShapeViewDelegate {
    func willApplyCloneShape(_ sender: UIButton)
    func willChangeShape(_ sender: UIButton, type: ShapeType)
    func willApplyGradientShape(_ sender: UIButton)
    func willApplyPlainColorShape(_ sender: UIButton)
    func willApplyShadowShape(_ slider: SliderMenu)
    func willApplyAlphaShape(_ slider: SliderMenu)
    func willApplyPolygonShape(_ slider: SliderMenu)
    func onSliderValue(_ slider: SliderMenu)
}

class MenuShapeView: UIView {
    internal var delegate: MenuShapeViewDelegate?
    
    private var buttons: [UIButton] = []
    
    private var stackView: UIStackView?
    private var btnCircle: UIButton?
    private var btnRectangle: UIButton?
    private var btnTriangle: UIButton?
    private var btnGradient: UIButton?
    private var btnPlainColor: UIButton?
    private var btnShadow: UIButton?
    private var btnAlpha: UIButton?
    private var btnPolygon: UIButton?
    private var btnClone: UIButton?
    
    private var sliderView: SliderMenu?
    
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
    
    public func initMenu() {
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true

        guard let window = UIApplication.window else {return}
        window.addSubview(self)
        menuSizeConstraints()
    }
    
    private func initLayout() {
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
    
    private func initStackView() {
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
    
    private func initAllButton() {
        initBtnClone()
        initBtnCircle()
        initBtnRectangle()
        initBtnTriangle()
        initBtnPolygon()
        initBtnPlainColor()
        initBtnGradient()
        initBtnShadow()
        initBtnAlpha()
    }
    
    private func initBtnClone() {
        btnClone = UIButton()
        guard let btnClone = self.btnClone else {return}
        btnClone.addTarget(self, action: #selector(cloneShape(_:)), for: .touchUpInside)
        config(btnClone, name: "copy", for: .highlighted)
    }
    
    private func initBtnCircle() {
        btnCircle = UIButton()
        guard let btnCircle = self.btnCircle else {return}
        btnCircle.addTarget(self, action: #selector(changeShape(_:)), for: .touchUpInside)
        config(btnCircle, name: "circle", for: .highlighted)
    }
    
    private func initBtnRectangle() {
        btnRectangle = UIButton()
        guard let btnRectangle = self.btnRectangle else {return}
        btnRectangle.addTarget(self, action: #selector(changeShape(_:)), for: .touchUpInside)
        config(btnRectangle, name: "square-of-rounded-corners", for: .highlighted)
    }
    
    private func initBtnTriangle() {
        btnTriangle = UIButton()
        guard let btnTriangle = self.btnTriangle else {return}
        btnTriangle.addTarget(self, action: #selector(changeShape(_:)), for: .touchUpInside)
        config(btnTriangle, name: "bleach", for: .highlighted)
    }
    
    private func initBtnGradient() {
        btnGradient = UIButton()
        guard let btnGradient = self.btnGradient else {return}
        btnGradient.addTarget(self, action: #selector(gradientShape(_:)), for: .touchUpInside)
        config(btnGradient, name: "gradient", for: .highlighted)
    }
    
    private func initBtnPlainColor() {
        btnPlainColor = UIButton()
        guard let btnPlainColor = self.btnPlainColor else {return}
        btnPlainColor.addTarget(self, action: #selector(plainColorShape(_:)), for: .touchUpInside)
        config(btnPlainColor, name: "bucket", for: .highlighted)
    }
    
    private func initBtnShadow() {
        btnShadow = UIButton()
        guard let btnShadow = self.btnShadow else {return}
        btnShadow.addTarget(self, action: #selector(shadowShape(_:)), for: .touchUpInside)
        config(btnShadow, name: "shadow", for: .selected)
    }
    
    private func initBtnAlpha() {
        btnAlpha = UIButton()
        guard let btnAlpha = self.btnAlpha else {return}
        btnAlpha.addTarget(self, action: #selector(alphaShape(_:)), for: .touchUpInside)
        config(btnAlpha, name: "transparency", for: .selected)
    }
    
    private func initBtnPolygon() {
        btnPolygon = UIButton()
        guard let btnPolygon = self.btnPolygon else {return}
        btnPolygon.addTarget(self, action: #selector(changeShape(_:)), for: .touchUpInside)
        btnPolygon.addTarget(self, action: #selector(polygonShape(_:)), for: .touchUpInside)
        config(btnPolygon, name: "hexagonal", for: .selected)
    }
    
    private func config(_ button: UIButton, name: String, for state: UIControl.State, highlightedColor: UIColor = .lightGray, normalColor: UIColor = .white) {
        guard let icon = UIImage(named: name) else {return}
        configButton(button, icon: icon, for: state, highlightedColor: highlightedColor, normalColor: normalColor)
    }
    
    private func configButton(_ button: UIButton, icon: UIImage, for state: UIControl.State, highlightedColor: UIColor, normalColor: UIColor) {
        button.setImage(icon.configIconColor(normalColor), for: .normal)
        button.setImage(icon.configIconColor(highlightedColor), for: state)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        stackView?.addArrangedSubview(button)
        button.heightAnchor.constraint(equalTo: stackView!.widthAnchor, multiplier: 0.4).isActive = true
        buttons.append(button)
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
    
    private func menuSizeConstraints() {
        guard let window = UIApplication.window else { return }
        let height = (window.frame.width > window.frame.height) ? window.widthAnchor : window.heightAnchor
        let width = (window.frame.width > window.frame.height) ? window.heightAnchor : window.widthAnchor
        
        trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
        centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        heightAnchor.constraint(equalTo: height, multiplier: 0.5).isActive = true
        widthAnchor.constraint(equalTo: width, multiplier: 0.1).isActive = true
    }
}

extension MenuShapeView {
    @objc private func changeShape(_ sender: UIButton) {
        self.hideSlider()
        self.selectButton(sender)
        switch sender {
            case btnCircle:
                delegate?.willChangeShape(sender, type: ShapeType.circle)
            case btnTriangle:
                delegate?.willChangeShape(sender, type: ShapeType.triangle)
            case btnRectangle:
                delegate?.willChangeShape(sender, type: ShapeType.rectangle)
            case btnPolygon:
                delegate?.willChangeShape(sender, type: ShapeType.polygon)
            default:
                delegate?.willChangeShape(sender, type: ShapeType.circle)
        }
    }
    
    @objc private func cloneShape(_ sender: UIButton) {
        self.hideSlider()
        self.selectButton(sender)
        delegate?.willApplyCloneShape(sender)
    }
    
    @objc private func gradientShape(_ sender: UIButton) {
        self.hideSlider()
        self.selectButton(sender)
        delegate?.willApplyGradientShape(sender)
    }
    
    @objc private func plainColorShape(_ sender: UIButton) {
        self.hideSlider()
        self.selectButton(sender)
        delegate?.willApplyPlainColorShape(sender)
    }
    
    @objc private func shadowShape(_ sender: UIButton) {
        self.selectButton(sender)
        self.showSlider(.shadow)
    }
    
    @objc private func alphaShape(_ sender: UIButton) {
        self.selectButton(sender)
        self.showSlider(.alpha)
    }
    
    @objc private func polygonShape(_ sender: UIButton) {
        self.selectButton(sender)
        self.showSlider(.polygon)
    }
    
    @objc private func onSliderValueChanged(_ sender: SliderMenu) {
        switch sender.type {
            case .shadow:
                delegate?.willApplyShadowShape(sender)
            case .alpha:
                delegate?.willApplyAlphaShape(sender)
            case .polygon:
                delegate?.willApplyPolygonShape(sender)
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
        
        if btnPolygon!.isSelected {
            self.showSlider(.polygon)
        }
    }
}
