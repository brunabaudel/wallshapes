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
    func refreshColorItemHandle()
    func shareHandle()
    
    func saveFileHandle(completion: @escaping () -> Void)
    func saveToPhotosHandle(completion: @escaping () -> Void)
    func renameHandle(completion: @escaping () -> Void)
    func cancelHandle(completion: @escaping () -> Void)
    func deleteHandle(completion: @escaping () -> Void)
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
        super.init(rootViewController: rootViewController)
        setupNavigationController()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNavigationController()
    }

    public func setupNavigationController() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = .init(white: 0.3, alpha: 0.3)
        
        self.navigationBar.standardAppearance = navBarAppearance
        self.navigationBar.scrollEdgeAppearance = navBarAppearance
        self.navigationBar.compactScrollEdgeAppearance = navBarAppearance
        self.navigationBar.compactAppearance = navBarAppearance
        self.navigationBar.tintColor = .white

        self.navigationRightItems = setupNavigationRightItems()
        self.navigationLeftItems = setupNavigationLeftItems()
        setupNavigationItems()
    }
}

// MARK: - Navbar items

extension WallshapesNavigationController {
    private func setupNavigationRightItems() -> [UIBarButtonItem] {
        return [
                UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemHandle)),
                configBarButtons("bucket", size: 23, action: #selector(refreshColorItemHandle)),
            ]
    }

    private func setupNavigationLeftItems() -> [UIBarButtonItem] {
        return [
                UIBarButtonItem(title: "Done", primaryAction: nil, menu: createAttributeMenu()),
                configBarButtons("square.and.arrow.up", isSystemSymbol: true, action: #selector(shareHandle))
            ]
    }

    private func setupNavigationItems() {
        guard let navItem = navItem else {return}
        navItem.rightBarButtonItems = self.navigationRightItems
        navItem.leftBarButtonItems = self.navigationLeftItems
    }

    @objc private func refreshColorItemHandle() {
        wallshapesDelegate?.refreshColorItemHandle()
    }

    @objc private func addItemHandle() {
        wallshapesDelegate?.addItemHandle()
    }
    
    @objc private func shareHandle() {
        wallshapesDelegate?.shareHandle()
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
                UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"), attributes: .destructive, handler: { (_) in
                    self.wallshapesDelegate?.cancelHandle(completion: self.doneAction!)
                }),
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
                    self.wallshapesDelegate?.deleteHandle(completion: self.doneAction!)
                })
        ]
        
        return UIMenu(title: "", children: menuActions)
    }
    
    private func configBarButtons(_ title: String, size: CGFloat = 20, isSystemSymbol: Bool = false, action: Selector?) -> UIBarButtonItem {
        guard let icon = createIcon(title, size: size, isSystemSymbol: isSystemSymbol) else {return UIBarButtonItem()}
        return UIBarButtonItem(image: icon, style: .plain, target: self, action: action)
    }

    private func createIcon(_ title: String, size: CGFloat = 20, isSystemSymbol: Bool) -> UIImage? {
        return isSystemSymbol ? UIImage(systemName: title) :
                                UIImage(named: title)?.resize(targetSize: CGSize(width: size, height: size))
    }
}
