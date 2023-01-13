//
//  WallshapesNavigationController.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/10/21.
//

import UIKit
import SwiftUI

protocol WallshapesNavigationControllerDelegate: AnyObject {
    func addItemHandle()
    func refreshGradientItemHandle()
    func refreshPlainColorItemHandle()
    func changeViewSizeHandle()
    func clearItemHandle()
    func shareHandle()
    func deleteViewHandle(_ isActive: Bool)
    func saveToPhotosHandle(completion: @escaping () -> Void)
    func saveFileHandle(completion: @escaping () -> Void)
    func deleteHandle(completion: @escaping () -> Void)
    func renameHandle(completion: @escaping () -> Void)
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
//                configBarButtons("trash", action: #selector(deleteViewHandle))
        ]
    }

    private func setupNavigationLeftItems() -> [UIBarButtonItem] {
        return [
//            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveFileHandle)),
//                UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearItemHandle)),
                UIBarButtonItem(title: "Done", primaryAction: nil, menu: createAttributeMenu()),
                configBarButtons("square.and.arrow.up", isSystemSymbol: true, action: #selector(shareHandle))
        ]
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
    
    @objc private func shareHandle() {
        wallshapesDelegate?.shareHandle()
    }
    
    private func configBarButtons(_ title: String, size: CGFloat = 20, isSystemSymbol: Bool = false, action: Selector?) -> UIBarButtonItem {
        guard let icon = createIcon(title, size: size, isSystemSymbol: isSystemSymbol) else {return UIBarButtonItem()}
        return UIBarButtonItem(image: icon, style: .plain, target: self, action: action)
    }

    private func createIcon(_ title: String, size: CGFloat = 20, isSystemSymbol: Bool) -> UIImage? {
        return isSystemSymbol ? UIImage(systemName: title) :
                                UIImage(named: title)?.resize(targetSize: CGSize(width: size, height: size))
    }
    
    func createAttributeMenu() -> UIMenu  {
        let menuActions: [UIAction] = [
                UIAction(title: "Save", image: UIImage(systemName: "square.and.arrow.down"), handler: { (_) in
                    self.wallshapesDelegate?.saveFileHandle(completion: self.doneAction!)
                }),
                UIAction(title: "Save to Photos", image: UIImage(systemName: "square.and.arrow.down.on.square"), handler: { (_) in
                    self.wallshapesDelegate?.saveToPhotosHandle(completion: self.doneAction!)
                }),
                UIAction(title: "Rename", image: UIImage(systemName: "pencil"), handler: { (_) in
                    self.wallshapesDelegate?.renameHandle(completion: self.doneAction!)
                }),
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
                    self.wallshapesDelegate?.deleteHandle(completion: self.doneAction!)
                })
        ]
        
        return UIMenu(title: "", children: menuActions)
    }
}
