//
//  WallshapesNavigationController.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/10/21.
//

import UIKit

protocol WallshapesNavigationControllerDelegate: AnyObject {
    func addItemHandle()
    func refreshGradientItemHandle()
    func refreshPlainColorItemHandle()
    func changeViewSizeHandle()
    func saveItemHandle()
    func clearItemHandle()
}

final class WallshapesNavigationController: UINavigationController {
    internal weak var wallshapesDelegate: WallshapesNavigationControllerDelegate?

    override var shouldAutorotate: Bool {
        if !viewControllers.isEmpty {
            if topViewController!.isKind(of: WallshapesViewController.self) {
                return false
            }
        }
        return true
    }
    
    private var isSelected: Bool = false

    override init(rootViewController: UIViewController) {
        if #available(iOS 13.0, *) {
            super.init(rootViewController: rootViewController)
        } else {
            super.init(nibName: nil, bundle: nil)
            self.viewControllers = [rootViewController]
        }
        setupNavigationController()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNavigationController()
    }

    public func setupNavigationController() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.tintColor = .white
        setupNavigationItems()
    }

    private func setupNavigationItems() {
        guard let visibleViewController = self.visibleViewController as? WallshapesViewController else {return}
        let navItems = visibleViewController.navigationItem

        navItems.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemHandle)),
            configBarButtons("gradient", action: #selector(refreshGradientItemHandle)),
            configBarButtons("bucket", size: 23, action: #selector(refreshPlainColorItemHandle)),
            configBarButtons("crop", action: #selector(changeViewSizeHandle))]

        navItems.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItemHandle)),
            UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearItemHandle))]
    }

    @objc private func changeViewSizeHandle() {
        wallshapesDelegate?.changeViewSizeHandle()
    }

    @objc private func refreshPlainColorItemHandle() {
        wallshapesDelegate?.refreshPlainColorItemHandle()
    }

    @objc private func refreshGradientItemHandle() {
        wallshapesDelegate?.refreshGradientItemHandle()
    }

    @objc private func addItemHandle() {
        wallshapesDelegate?.addItemHandle()
    }

    @objc private func clearItemHandle() {
        wallshapesDelegate?.clearItemHandle()
    }

    @objc private func saveItemHandle() {
        wallshapesDelegate?.saveItemHandle()
    }

    private func configBarButtons(_ title: String, size: CGFloat = 20, action: Selector?) -> UIBarButtonItem {
        guard let icon = createIcon(title, size: size) else {return UIBarButtonItem()}
        return UIBarButtonItem(image: icon, style: .plain, target: self, action: action)
    }
    
    private func createIcon(_ title: String, size: CGFloat = 20) -> UIImage? {
        return UIImage(named: title)?
            .resize(targetSize: CGSize(width: size, height: size))
    }
}
