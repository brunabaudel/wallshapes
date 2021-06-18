//
//  WallshapesViewController.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class WallshapesViewController: UIViewController {
    private var wallshapeView: WallshapeView?

    override var prefersStatusBarHidden: Bool {
      return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let nav = self.navigationController as? WallshapesNavigationController else {return}
        nav.wallshapesDelegate = self
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
    func gridViewHandle() {
        wallshapeView?.gridView()
    }

    func changeViewSizeHandle() {
        wallshapeView?.resizeContentView()
    }

    func refreshPlainColorItemHandle() {
        wallshapeView?.chooseColor()
    }

    func refreshGradientItemHandle() {
        wallshapeView?.chooseColors(2)
    }

    func addItemHandle() {
        wallshapeView?.addShape()
    }

    func clearItemHandle() {
        UIAlertController.alertView("Clear all", message: "Do you want to erase all shapes?", isCancel: true) {
            self.wallshapeView?.clearShapes()
        }.showAlert(self)
    }

    func saveItemHandle() {
        wallshapeView?.saveFile()
        wallshapeView?.saveToPhotos(title: "Saving...")
    }

    func saveFileHandle() {
        wallshapeView?.saveFile()
    }
}
