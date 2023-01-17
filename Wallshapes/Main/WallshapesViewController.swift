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
    private var menuNavControl: MenuNavControl?
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
        self.menuNavControl = MenuNavControl(wallshapeView)
        guard let menuShapeControl = self.menuShapeControl, let menuNavControl = menuNavControl, let wallshape = self.wallshape else {return}
        self.wallshapeViewControl = WallshapeViewControl(wallshapeView, with: wallshape, menuShapeControl: menuShapeControl, menuNavControl: menuNavControl)
        self.gesturesControl = ShapeGesturesControl(wallshapeView, menuShapeControl: menuShapeControl, menuNavControl: menuNavControl)
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
    func addItemHandle() {
        wallshapeViewControl?.addShape()
    }
    
    func refreshColorItemHandle() {
        wallshapeViewControl?.menuColor()
    }
    
    
    func shareHandle() -> [UIImage] {
        guard let wallshape = self.wallshape, let image = wallshapeViewControl?.createImage(fileName: wallshape.fileName) else { return [] }
        return [image]
    }

    func saveFileHandle(completion: @escaping () -> Void) {
        guard let wallshape = self.wallshape else { return }
        wallshapeViewControl?.saveFileAndThumbnail(wallshape: wallshape, completion: completion)
    }
    
    func saveToPhotosHandle(completion: @escaping () -> Void) {
        guard let wallshape = self.wallshape else { return }
        wallshapeViewControl?.saveToPhotos(wallshape: wallshape, message: "Saving...", completion: completion)
    }

    func renameHandle(completion: @escaping () -> Void) {
        guard let wallshape = self.wallshape else { return }
        let textField = UITextField()
        textField.text = wallshape.name
        textField.delegate = self
        textField.placeholder = "Wallshape name"
        
        let alert = UIAlertController.alertWithTextField("Rename", isCancel: true, textField: textField)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { okAction -> Void in
            if let textFields = alert.textFields, let textField = textFields.first {
                wallshape.name = textField.text ?? ""
                self.wallshapeViewControl?.rename(wallshape: wallshape, completion: completion)
            }
        })
        
        alert.addAction(okAction)
        alert.showAlert(self)
    }
    
    func cancelHandle(completion: @escaping () -> Void) {
        wallshapeViewControl?.cancel(completion: completion)
    }
    
    func deleteHandle(completion: @escaping () -> Void) {
        guard let wallshape = self.wallshape else { return }
        wallshapeViewControl?.delete(wallshape: wallshape, completion: completion)
    }
}

extension WallshapesViewController: UITextFieldDelegate {}
