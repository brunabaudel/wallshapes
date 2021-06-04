//
//  UIButton+Extension.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 5/12/21.
//

import UIKit

extension UIButton {
    func config(_ name: String, for state: UIControl.State,
                highlightedColor: UIColor = .lightGray, normalColor: UIColor = .white) {
        guard let icon = UIImage(named: name) else {return}
        configButton(icon, for: state, highlightedColor: highlightedColor, normalColor: normalColor)
    }

    private func configButton(_ icon: UIImage, for state: UIControl.State,
                              highlightedColor: UIColor, normalColor: UIColor) {
        setImage(icon.configIconColor(normalColor), for: .normal)
        setImage(icon.configIconColor(highlightedColor), for: state)
        imageView?.contentMode = .scaleAspectFit
        translatesAutoresizingMaskIntoConstraints = false
    }
}
