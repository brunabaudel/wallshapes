//
//  WallShapesViewController.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

class WallShapesViewController: UIViewController {
    private var randomGradientView: RandomGradientView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        initSubviews()
    }
    
    private func initSubviews() {
        randomGradientView = RandomGradientView(frame: self.view.bounds)
        guard let randomGradientView = self.randomGradientView else {return}
        self.view.addSubview(randomGradientView)
    }
    
    private func setupNavigationController() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemHandle)),
            configBarButtons(name: "gradient", action: #selector(refreshGradientItemHandle)),
            configBarButtons(name: "bucket", action: #selector(refreshPlainColorItemHandle)),]
        
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItemHandle)),
            UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearItemHandle))]
        
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    private func configBarButtons(name: String, action: Selector?) -> UIBarButtonItem {
        guard let icon = UIImage(named: name)?.resize(targetSize: CGSize(width: 20, height: 20)) else {return UIBarButtonItem()}
        return UIBarButtonItem(image: icon, style: .plain, target: self, action: action)
    }
    
    @objc private func refreshPlainColorItemHandle() {
        randomGradientView?.chooseColor()
    }
    
    @objc private func refreshGradientItemHandle() {
        randomGradientView?.chooseColors(2)
    }
    
    @objc private func addItemHandle() {
        randomGradientView?.addShape()
    }
    
    @objc private func clearItemHandle() {
        randomGradientView?.clearShapes()
    }
    
    @objc private func saveItemHandle() {
        guard let image = UIImage.imageWithView(view).toPNG() else {return}
        saveToPhotoLibrary(image)
    }
    
    private func saveToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(finishWriteImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func finishWriteImage(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if (error != nil) {
            print("error occurred: \(String(describing: error))")
            self.alertOK("Error", message: "Oops.. Something went wrong.")
        } else {
            self.alertOK("Success", message: "The Wallshape was saved on the Photo Library.")
        }
    }
    
    private func alertOK(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
