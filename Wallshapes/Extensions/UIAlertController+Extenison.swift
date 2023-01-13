//
//  UIAlertController.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/10/21.
//

import UIKit

extension UIAlertController {
    class func alertView(_ title: String,
                         message: String,
                         titleCancel: String = "Cancel",
                         titleOK: String = "OK",
                         isCancel: Bool = false,
                         okAction: @escaping () -> Void = {}) -> UIAlertController {
        let alert = Self(title: title, message: message, preferredStyle: .alert)
        if isCancel {
            alert.addAction(UIAlertAction(title: titleCancel, style: .cancel))
        }
        alert.addAction(UIAlertAction(title: titleOK, style: .default, handler: { _ in okAction() }))
        return alert
    }

    func showAlert(_ vcr: UIViewController) {
        vcr.present(self, animated: true)
    }
    
    class func alertWithTextField(_ title: String,
                                  message: String = "",
                                  titleCancel: String = "Cancel",
                                  titleOK: String = "OK",
                                  isCancel: Bool = false,
                                  textField: UITextField) -> UIAlertController {
        let alert = Self(title: title, message: message, preferredStyle: .alert)
        
        if isCancel {
            alert.addAction(UIAlertAction(title: titleCancel, style: .cancel))
        }
        
        alert.addTextField { (uiTextField : UITextField!) in
            uiTextField.placeholder = textField.placeholder
            uiTextField.delegate = textField.delegate
        }
        return alert
    }
}
