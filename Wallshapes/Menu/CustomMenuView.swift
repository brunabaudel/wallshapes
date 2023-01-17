//
//  CustomMenuView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 5/22/21.
//

import UIKit

protocol CustomMenuDelegate: AnyObject {
    associatedtype EnumType: CaseIterable
    static func allCases() -> [EnumType]
    static func extraCases() -> [EnumType]
    static func imageNameBy(_ type: EnumType) -> String
    static func state(_ type: EnumType) -> UIControl.State
}

final class TypeButton<T: CustomMenuDelegate>: UIButton {
    var type: T.EnumType?
    var color: UIColor?
}

protocol CustomMenuViewDelegate: AnyObject {
    func onClickMenu(_ sender: UIButton)
}

final class CustomMenuView<T: CustomMenuDelegate>: UIView {
    typealias CustomMenu = T

    internal weak var delegate: CustomMenuViewDelegate?

    private var selectedButtons: [UIButton] = []
    private var mainMenu: UIView?
    private var extraMenu: UIView?
    
    private var mainMenuHeightMultiplier: Double = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if CustomMenu.extraCases().count >= 1 {
            initExtraButtonsStackView()
        }
        
        initAllButtonsStackView()
    }

    private func initLayout() {
        backgroundColor = .clear
    }

    private func initAllButtonsStackView() {
        self.mainMenu = createMenu()
        guard let mainMenu = self.mainMenu else {return}
        let stackView = createStackView(menu: mainMenu)
        
        for caseType in CustomMenu.allCases() {
            let button = createButton(caseType: caseType)
            stackView.addArrangedSubview(button)
            button.heightAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.45).isActive = true
        }
        
        mainMenu.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        mainMenu.heightAnchor.constraint(equalTo: heightAnchor, multiplier: mainMenuHeightMultiplier).isActive = true
    }
    
    private func initExtraButtonsStackView() {
        self.extraMenu = createMenu()
        guard let extraMenu = self.extraMenu else {return}
        
        if CustomMenu.extraCases().count == 1 {
            let button = createButton(caseType: CustomMenu.extraCases().first!)
            extraMenu.addSubview(button)

            extraMenu.topAnchor.constraint(equalTo: topAnchor).isActive = true
            extraMenu.heightAnchor.constraint(equalTo: widthAnchor).isActive = true

            button.centerXAnchor.constraint(equalTo: extraMenu.centerXAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: extraMenu.centerYAnchor).isActive = true
            button.heightAnchor.constraint(equalTo: extraMenu.widthAnchor, multiplier: 0.45).isActive = true
            button.widthAnchor.constraint(equalTo: extraMenu.widthAnchor, multiplier: 0.95).isActive = true
            
            mainMenuHeightMultiplier = (Double(CustomMenu.allCases().count + 2) / 10) + 0.01
            
        } else {
            let stackView = createStackView(menu: extraMenu)

            for caseType in CustomMenu.extraCases() {
                let button = createButton(caseType: caseType)
                stackView.addArrangedSubview(button)
                button.heightAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.45).isActive = true
            }

            extraMenu.topAnchor.constraint(equalTo: topAnchor).isActive = true
            extraMenu.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Double(CustomMenu.extraCases().count * 2) / 10).isActive = true
            
            mainMenuHeightMultiplier = Double(CustomMenu.allCases().count * 2) / 10
        }
    }
    
    private func createMenu() -> UIView {
        let menu = UIView()
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.backgroundColor = .init(white: 0.6, alpha: 0.3)
        menu.clipsToBounds = true
        menu.layer.cornerRadius = 10
        menu.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        menu.layer.shadowColor = UIColor.white.cgColor
        menu.layer.shadowOffset = CGSize.zero
        menu.layer.shadowOpacity = 0.5
        menu.layer.shadowRadius = 1
        menu.layer.masksToBounds = false
        
        addSubview(menu)
        
        menu.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        menu.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        return menu
    }
        
    private func createButton(caseType: any CaseIterable, color: UIColor = .white) -> UIButton {
        let button = TypeButton<CustomMenu>()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.type = caseType as? T.EnumType
        button.config(CustomMenu.imageNameBy(caseType as! T.EnumType), for: CustomMenu.state(caseType as! T.EnumType), normalColor: color)
        button.addTarget(self, action: #selector(onClickView(_:)), for: .touchUpInside)
        if CustomMenu.state(caseType as! T.EnumType) == .selected {selectedButtons.append(button)}
        return button
    }
    
    private func createStackView(menu: UIView) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        
        menu.addSubview(stackView)
        
        stackView.centerXAnchor.constraint(equalTo: menu.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: menu.centerYAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: menu.heightAnchor, multiplier: 0.90).isActive = true
        stackView.widthAnchor.constraint(equalTo: menu.widthAnchor, multiplier: 0.95).isActive = true
        
        return stackView
    }
    
    @objc private func onClickView(_ sender: UIButton) {
        delegate?.onClickMenu(sender)
        selectButton(sender)
    }

    private func selectButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        _ = selectedButtons.map { if sender != $0 { $0.isSelected = false }}
    }

    public func unselectAllButtons() {
        _ = selectedButtons.map { $0.isSelected = false }
    }
}
