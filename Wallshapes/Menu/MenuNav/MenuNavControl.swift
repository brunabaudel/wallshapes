//
//  MenuNavControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 15/01/2023.
//

import UIKit

protocol MenuNavControlDelegate: AnyObject {
    func onColorMenu(_ sender: TypeButton<ColorMenuView>, wallshapeView: WallshapeView)
}

final class MenuNavControl {
    internal weak var delegate: MenuNavControlDelegate?

    private weak var wallshapeview: WallshapeView?
    private var navViewControl: NavViewControl?

    private var menuColorView: CustomMenuView<ColorMenuView>?

    init(_ wallshapeview: WallshapeView) {
        self.wallshapeview = wallshapeview
        self.navViewControl = NavViewControl(self)
        initColorMenuOnWindow()
    }
    
    private func initColorMenuOnWindow() {
        menuColorView = CustomMenuView<ColorMenuView>(frame: CGRect.zero)
        guard let menuColorView = self.menuColorView else {return}
        menuColorView.translatesAutoresizingMaskIntoConstraints = false
        menuColorView.isHidden = true
        menuColorView.delegate = self

        guard let window = UIApplication.window, let rootViewController = window.rootViewController else {return}
        rootViewController.view.addSubview(menuColorView)

        menuColorView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor).isActive = true
        menuColorView.centerYAnchor.constraint(equalTo: rootViewController.view.centerYAnchor).isActive = true
        menuColorView.heightAnchor.constraint(equalTo: rootViewController.view.heightAnchor, multiplier: 0.21).isActive = true
        menuColorView.widthAnchor.constraint(equalTo: rootViewController.view.heightAnchor, multiplier: 0.075).isActive = true
    }
}

// MARK: - Color methods

extension MenuNavControl {
    public func showMenu() {
        guard let menuColorView = self.menuColorView else {return}
        menuColorView.isHidden = !menuColorView.isHidden
    }

    func hideMenu() {
        guard let menuColorView = self.menuColorView else {return}
        menuColorView.isHidden = true
    }
}

extension MenuNavControl: CustomMenuViewDelegate {
    func onClickMenu(_ sender: UIButton) {
        switch sender {
        case is TypeButton<ColorMenuView>:
            guard let sender = sender as? TypeButton<ColorMenuView>, let wallshapeView = self.wallshapeview else {return}
            delegate?.onColorMenu(sender, wallshapeView: wallshapeView)
        default:
            NSLog("Error")
        }
    }
}
