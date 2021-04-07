//
//  WallShapesViewController.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

class WallshapesNavigationController: UINavigationController {
    override var shouldAutorotate: Bool {
        if !viewControllers.isEmpty {
            if topViewController!.isKind(of: WallshapesViewController.self) {
                return false
            }
        }
        return true
    }
}

class WallshapesViewController: UIViewController {
    private var randomGradientView: RandomGradientView!
    private var renderIndicatorView: RenderIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
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
            configBarButtons(name: "bucket", targetSize: CGSize(width: 23, height: 23), action: #selector(refreshPlainColorItemHandle)),
            configBarButtons(name: "crop", action: #selector(changeViewSizeHandle)),]
        
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItemHandle)),
            UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearItemHandle))]
        
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    private func configBarButtons(name: String, targetSize: CGSize = CGSize(width: 20, height: 20), action: Selector?) -> UIBarButtonItem {
        guard let icon = UIImage(named: name)?.resize(targetSize: targetSize) else {return UIBarButtonItem()}
        return UIBarButtonItem(image: icon, style: .plain, target: self, action: action)
    }
    
    @objc private func changeViewSizeHandle() {
        randomGradientView?.resizeRandomBackgroundView()
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
        self.alertView("Clear all", message: "Do you want to erase all shapes?", isCancel: true) {
            self.randomGradientView?.clearShapes()
        }
    }
    
    @objc private func saveItemHandle() {
        guard let randomGradientView = self.randomGradientView else {return}
        guard var image = UIImage.imageWithView(randomGradientView).toPNG() else {return}
        image = image.crop(randomGradientView.randomBackgroundViewFrame(), sizeView: randomGradientView.frame.size)!
        saveToPhotoLibrary(image.toPNG()!)
    }
    
    private func saveToPhotoLibrary(_ image: UIImage) {
        initRenderindicatorView("Saving...")
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(finishWriteImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func finishWriteImage(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if (error != nil) {
            print("error occurred: \(String(describing: error))")
            self.alertView("Error", message: "Oops.. Something went wrong.")
        } else {
            renderIndicatorView?.finishAnimation("Image saved.")
        }
    }
    
    private func initRenderindicatorView(_ message: String) {
        self.renderIndicatorView = RenderIndicatorView(frame: view.frame, message: message)
        guard let renderindicatorView = self.renderIndicatorView else {return}
        renderindicatorView.translatesAutoresizingMaskIntoConstraints = false
        renderindicatorView.center = view.center
        view.addSubview(renderindicatorView)
        
        renderindicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        renderindicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        renderindicatorView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15).isActive = true
        renderindicatorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    }
    
    private func alertView(_ title: String, message: String, isCancel: Bool = false, okAction: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if isCancel {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in okAction() }))
        self.present(alert, animated: true)
    }
}
