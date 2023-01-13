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
    public var wallshape: Wallshape?

    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let nav = self.navigationController as? WallshapesNavigationController else {return}
        nav.wallshapesDelegate = self
        guard let wallshapeView = self.wallshapeView else {return}
        self.menuShapeControl = MenuShapeControl(wallshapeView)
        guard let menuShapeControl = self.menuShapeControl, let wallshape = self.wallshape else {return}
        self.wallshapeViewControl = WallshapeViewControl(wallshapeView, with: wallshape, menuControl: menuShapeControl)
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

    func saveToPhotosHandle(completion: @escaping () -> Void) {
        guard let wallshape = self.wallshape else { return }
        wallshapeViewControl?.saveFileAndThumbnail(wallshape: wallshape)
        wallshapeViewControl?.saveToPhotos(wallshape: wallshape, message: "Saving...", completion: completion)
    }

    func saveFileHandle(completion: @escaping () -> Void) {
        guard let wallshape = self.wallshape else { return }
        wallshapeViewControl?.saveFileAndThumbnail(wallshape: wallshape, completion: completion)
    }
    
    func renameHandle(completion: @escaping () -> Void) {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "name"
        
        let alert = UIAlertController.alertWithTextField("Rename", isCancel: true, textField: textField)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { okAction -> Void in
            if let textFields = alert.textFields, let textField = textFields.first {
                guard let wallshape = self.wallshape else { return }
                wallshape.name = textField.text ?? ""
                self.wallshapeViewControl?.rename(wallshape: wallshape, completion: completion)
            }
        })
        
        alert.addAction(okAction)
        alert.showAlert(self)
    }
    
    func deleteHandle(completion: @escaping () -> Void) {
        guard let wallshape = self.wallshape else { return }
        wallshapeViewControl?.delete(wallshape: wallshape, completion: completion)
    }
    
    func shareHandle() {
        guard let wallshape = self.wallshape, let image = wallshapeViewControl?.createImage(fileName: wallshape.fileName) else { return }
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension WallshapesViewController: UITextFieldDelegate {}
