//
//  CustomMenuView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 5/22/21.
//

import UIKit

public protocol IntegerProtocol {
    var rawValue: Int { get }
}

protocol CustomMenuDelegate: AnyObject {
    associatedtype EnumType: IntegerProtocol
    static func allCases() -> [EnumType]
    static func imageNameBy(_ type: EnumType) -> String
    static func state(_ type: EnumType) -> UIControl.State
}

final class TypeButton<T: CustomMenuDelegate>: UIButton {
    var type: T.EnumType?
}

protocol CustomMenuViewDelegate: AnyObject {
    func onClickMenu(_ sender: UIButton)
}

final class CustomMenuView<T: CustomMenuDelegate>: UIView {
    typealias CustomMenu = T

    internal weak var delegate: CustomMenuViewDelegate?

    private var stackView: UIStackView?
    private var selectedButtons: [UIButton] = []

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
        initStackView()
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
        initAllButtons()
        addSubview(stackView)

        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.90).isActive = true
        stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95).isActive = true
    }

    private func initAllButtons() {
        for caseType in CustomMenu.allCases() {
            let button = TypeButton<CustomMenu>()
            button.type = caseType
            button.config(CustomMenu.imageNameBy(caseType), for: CustomMenu.state(caseType))
            button.addTarget(self, action: #selector(onClickView(_:)), for: .touchUpInside)
            stackView?.addArrangedSubview(button)
            button.heightAnchor.constraint(equalTo: stackView!.widthAnchor, multiplier: 0.4).isActive = true
            if CustomMenu.state(caseType) == .selected {selectedButtons.append(button)}
        }
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
