//
//  WallshapesViewController.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class WallshapesViewController: UIViewController {
    private var wallshapeView: WallshapeView?
    private var wallshapeViewControl: WallshapeViewControl?
    private var gesturesControl: ShapeGesturesControl?
    private var menuShapeControl: MenuShapeControl?

    override var prefersStatusBarHidden: Bool {
      return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let nav = self.navigationController as? WallshapesNavigationController else {return}
        nav.wallshapesDelegate = self
        guard let wallshapeView = self.wallshapeView else {return}
        self.menuShapeControl = MenuShapeControl(wallshapeView)
        guard let menuShapeControl = self.menuShapeControl else {return}
        self.wallshapeViewControl = WallshapeViewControl(wallshapeView, menuControl: menuShapeControl)
        self.gesturesControl = ShapeGesturesControl(wallshapeView, menuControl: menuShapeControl)
    }

    override func loadView() {
        super.loadView()
        initSubviews()
    }

    private func initSubviews() {
        wallshapeView = WallshapeView(frame: view.frame)
        guard let wallshapeView = self.wallshapeView else {return}
        self.view.addSubview(wallshapeView)
    }
}

extension WallshapesViewController: WallshapesNavigationControllerDelegate {
    func deleteViewHandle(_ isActive: Bool) {
        wallshapeViewControl?.deleteShapeViews(isActive)
    }

    func changeViewSizeHandle() {
        wallshapeViewControl?.resizeContentView()
    }

    func refreshPlainColorItemHandle() {
        wallshapeViewControl?.chooseColor()
    }

    func refreshGradientItemHandle() {
        wallshapeViewControl?.chooseColors(2)
    }

    func addItemHandle() {
        wallshapeViewControl?.addShape()
    }

    func clearItemHandle() {
        UIAlertController.alertView("Clear all", message: "Do you want to erase all shapes?", isCancel: true) {
            self.wallshapeViewControl?.clearShapes()
        }.showAlert(self)
    }

    func saveItemHandle() {
        wallshapeViewControl?.saveFile()
        wallshapeViewControl?.saveToPhotos(title: "Saving...")
    }

    func saveFileHandle() {
        wallshapeViewControl?.saveFile()
    }
}
