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
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshGradientItemHandle)),
            UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(refreshPlainColorItemHandle))]
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .save, target: self, action:                                                             #selector(saveItemHandle)),
                                                  UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(clearItemHandle))]
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
