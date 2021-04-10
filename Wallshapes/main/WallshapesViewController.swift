//
//  WallshapesViewController.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

class WallshapesViewController: UIViewController {
    private var randomGradientView: RandomGradientView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.navigationController as! WallshapesNavigationController).wallshapesDelegate = self
    }
    
    override func loadView() {
        super.loadView()
        initSubviews()
    }
    
    private func initSubviews() {
        randomGradientView = RandomGradientView(frame: self.view.bounds)
        guard let randomGradientView = self.randomGradientView else {return}
        self.view.addSubview(randomGradientView)
    }
}

extension WallshapesViewController: WallshapesNavigationControllerDelegate {
    func changeViewSizeHandle() {
        randomGradientView?.resizeRandomBackgroundView()
    }

    func refreshPlainColorItemHandle() {
        randomGradientView?.chooseColor()
    }
    
    func refreshGradientItemHandle() {
        randomGradientView?.chooseColors(2)
    }
    
    func addItemHandle() {
        randomGradientView?.addShape()
    }
    
    func clearItemHandle() {
        UIAlertController.alertView("Clear all", message: "Do you want to erase all shapes?", isCancel: true) {
            self.randomGradientView?.clearShapes()
        }.showAlert(self)
    }

    func saveItemHandle() {
    }
}
