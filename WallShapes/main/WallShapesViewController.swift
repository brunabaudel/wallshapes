//
//  WallShapesViewController.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

class WallShapesViewController: UIViewController {
    var randomGradientView: RandomGradientView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        initSubviews()
    }
    
    func initSubviews() {
        randomGradientView = RandomGradientView(frame: self.view.bounds)
        guard let randomGradientView = self.randomGradientView else {return}
        self.view.addSubview(randomGradientView)
    }
    
    func setupNavigationController() {
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
    
    func configBarButtons(name: String, action: Selector?) -> UIBarButtonItem {
        guard let icon = UIImage(named: name)?.resize(targetSize: CGSize(width: 20, height: 20)) else {return UIBarButtonItem()}
        return UIBarButtonItem(image: icon, style: .plain, target: self, action: action)
    }
    
    @objc func refreshPlainColorItemHandle() {
        randomGradientView?.chooseColor()
    }
    
    @objc func refreshGradientItemHandle() {
        randomGradientView?.chooseColors(2)
    }
    
    @objc func addItemHandle() {
        randomGradientView?.addShape()
    }
    
    @objc func clearItemHandle() {
        randomGradientView?.clearShapes()
    }
    
    @objc func saveItemHandle() {
        let image = UIImage.imageWithView(self.view)
//        guard let renderImage = image.ciblur(forRect: view.frame, with: 15) else {return}
        let imageShare: [UIImage] = [image]
        let activityViewController = UIActivityViewController(activityItems: imageShare, applicationActivities: nil)
        activityViewController.modalPresentationStyle = .popover
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
