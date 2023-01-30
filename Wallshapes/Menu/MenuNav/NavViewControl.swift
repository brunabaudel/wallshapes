//
//  NavViewControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 15/01/2023.
//

import UIKit
import Combine

final class NavViewControl {
    private weak var menuNavControl: MenuNavControl?
    private var cancellable: AnyCancellable?
    private var gradientColors: [UIColor] = [.white, .white]

    init(_ menuNavControl: MenuNavControl) {
        self.menuNavControl = menuNavControl
        self.menuNavControl?.delegate = self
    }

    private func openColorPicker(_ sender: TypeButton<ColorMenuView>, wallshapeView: WallshapeView) -> UIColorPickerViewController? {
        let picker = UIColorPickerViewController()

        if sender.type == .plain {
            picker.selectedColor = sender.color ?? wallshapeView.contentView?.backgroundColor ?? .white
        }
        
        if sender.type == .gradient1 {
            picker.selectedColor = gradientColors.first ?? sender.color ?? .white
        }
        
        if sender.type == .gradient2 {
            picker.selectedColor = gradientColors.last ?? sender.color ?? .white
        }

        cancellable = picker.publisher(for: \.selectedColor)
            .sink { color in
                DispatchQueue.main.async {
                    sender.color = color
                    sender.alpha = color.alpha
                    let image = sender.currentImage?.tinted(with: color.withAlphaComponent(1))
                    sender.setImage(nil, for: .normal)
                    sender.setImage(image, for: .normal)
                    
                    if sender.type == .plain {
                        self.chooseColor(color, wallshapeView: wallshapeView)
                    }
                    
                    if sender.type == .gradient1 {
                        wallshapeView.contentView?.backgroundColor = .clear
                        self.gradientColors.remove(at: 0)
                        self.gradientColors.insert(color, at: 0)
                        self.chooseColors(self.gradientColors, wallshapeView: wallshapeView)
                    }
                    
                    if sender.type == .gradient2 {
                        wallshapeView.contentView?.backgroundColor = .clear
                        self.gradientColors.remove(at: 1)
                        self.gradientColors.insert(color, at: 1)
                        self.chooseColors(self.gradientColors, wallshapeView: wallshapeView)
                    }
                }
            }
        return picker
    }
    
    private func chooseColor(_ color: UIColor, wallshapeView: WallshapeView) {
        wallshapeView.contentView?.layer.sublayers?.removeAll(where: { layer in layer is CAGradientLayer })
        wallshapeView.contentView?.backgroundColor = color
    }
    
    private func chooseColors(_ colors: [UIColor], wallshapeView: WallshapeView) {
        guard let gradientLayer = (wallshapeView.contentView?.firstSublayer) as? CAGradientLayer else {
            addGradientLayer(with: colors, wallshapeView: wallshapeView)
            return
        }
        let cgColors = colors.map {$0.cgColor}
        gradientLayer.colors = cgColors
    }

    private func addGradientLayer(with colors: [UIColor], wallshapeView: WallshapeView) {
        let gradientLayer = initGradientLayer(colors, wallshapeView: wallshapeView)
        wallshapeView.contentView?.layer.sublayers?.removeAll(where: { layer in layer is CAGradientLayer })
        wallshapeView.contentView?.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func initGradientLayer(_ colors: [UIColor], wallshapeView: WallshapeView) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        let cgColors = colors.map {$0.cgColor}
        gradientLayer.frame = wallshapeView.contentView?.bounds ?? CGRect.zero
        gradientLayer.colors = cgColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }
}

extension NavViewControl: MenuNavControlDelegate {
    func onColorMenu(_ sender: TypeButton<ColorMenuView>, wallshapeView: WallshapeView) {
        guard let type = sender.type else {return}
        switch type {
        case .plain, .gradient1, .gradient2:
            guard let picker = openColorPicker(sender, wallshapeView: wallshapeView) else {return}
            guard let window = UIApplication.window, let rootViewController = window.rootViewController else {return}
            rootViewController.present(picker, animated: true)
        case .none:
            NSLog("Something went wrong")
        }
    }
}
