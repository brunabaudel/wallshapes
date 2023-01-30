//
//  AuthorizationAssests.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/13/21.
//

import UIKit
import Photos

final class AuthorizationAssests {
    internal func authorization(completionHandler: @escaping (Bool) -> Void) {
        if #available(iOS 14.0, *) {
            requestAuthorization14Plus(completionHandler: completionHandler)
        } else {
            requestAuthorization(completionHandler: completionHandler)
        }
    }

    @available(iOS 14, *)
    private func requestAuthorization14Plus(completionHandler: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .authorized {
            completionHandler(true)
        } else {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                self.requestAuthorizationHandler(status, completionHandler: completionHandler)
            }
        }
    }

    private func requestAuthorization(completionHandler: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            completionHandler(true)
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                self.requestAuthorizationHandler(status, completionHandler: completionHandler)
            }
        }
    }

    private func requestAuthorizationHandler(_ status: PHAuthorizationStatus,
                                             completionHandler: @escaping (Bool) -> Void) {
        if status == .authorized {
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }

    static public func openAppSettings(_ title: String, message: String, titleOK: String) {
        DispatchQueue.main.async {
            guard let window = UIApplication.window, let rootViewController = window.rootViewController else {return}
            UIAlertController.alertView(title, message: message, titleOK: titleOK, isCancel: true) {
                guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else {return}
                UIApplication.shared.open(settingUrl)
            }.showAlert(rootViewController)
        }
    }
}
