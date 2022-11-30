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
    func deleteViewHandle(_ isActive: Bool)
    func saveItemHandle(completion: @escaping () -> Void)
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

    private var isActive: Bool = false
    private var navigationRightItems: [UIBarButtonItem] = []
    private var navigationLeftItems: [UIBarButtonItem] = []
    
    var doneAction: (() -> Void)? = nil

    private var navItem: UINavigationItem? {
        guard let visibleViewController = self.visibleViewController as? WallshapesViewController else {return nil}
        return visibleViewController.navigationItem
    }

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
        self.navigationRightItems = setupNavigationRightItems()
        self.navigationLeftItems = setupNavigationLeftItems()
        setupNavigationItems()
    }

    private func setupNavigationRightItems() -> [UIBarButtonItem] {
        return [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemHandle)),
                configBarButtons("gradient", action: #selector(refreshGradientItemHandle)),
                configBarButtons("bucket", size: 23, action: #selector(refreshPlainColorItemHandle)),
//                configBarButtons("crop", action: #selector(changeViewSizeHandle)),
                configBarButtons("trash", action: #selector(deleteViewHandle))]
    }

    private func setupNavigationLeftItems() -> [UIBarButtonItem] {
        return [UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveItemHandle)),
                UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearItemHandle))]
    }

    private func setupNavigationItems() {
        guard let navItem = navItem else {return}
        navItem.rightBarButtonItems = self.navigationRightItems
        navItem.leftBarButtonItems = self.navigationLeftItems
    }

    private func setupNavigationItemsDelete() {
        guard let navItem = navItem else {return}
        navItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(deleteViewHandle))]
        navItem.leftBarButtonItems = []
    }

    @objc private func deleteViewHandle(_ sender: UIBarButtonItem) {
        isActive = !isActive
        if isActive {
            setupNavigationItemsDelete()
        } else {
            setupNavigationItems()
        }
        wallshapesDelegate?.deleteViewHandle(isActive)
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
        wallshapesDelegate?.saveItemHandle(completion: doneAction!)
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
