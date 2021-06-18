//
//  SaveImage.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/10/21.
//

import UIKit

final class SaveImage: NSObject {
    private static var renderIndicatorView: RenderIndicatorView?

    static public func save(_ title: String, view: UIView, frame: CGRect,
                            completion: @escaping () -> Void) {
        if #available(iOS 14.0, *) {
            AuthorizationAssests().authorization { authorized in
                if authorized {
                    DispatchQueue.main.async {
                        self.willSaveImage(title, view: view, rect: frame, completionHandler: completion)
                    }
                    return
                }
                self.showAppSettingsDialog()
            }
        } else {
            self.willSaveImage(title, view: view, rect: frame, completionHandler: completion)
        }
    }

    static private func willSaveImage(_ title: String, view: UIView, rect: CGRect,
                                      completionHandler: @escaping () -> Void) {
        self.showIndicator(with: title)
        guard let image = self.willPrepareImage(view, rect: rect, completionHandler: completionHandler) else {
            self.renderIndicatorView?.finishAnimation(SaveImageHandlerError.failed.message)
            return
        }
        self.writeToPhotoAlbum(image)
    }

    static private func writeToPhotoAlbum(_ image: UIImage) {
       UIImageWriteToSavedPhotosAlbum(image, self, #selector(writeToPhotoAlbumHandler), nil)
   }

    @objc static private func writeToPhotoAlbumHandler(_ image: UIImage, didFinishSavingWithError error: Error?,
                                                       contextInfo: UnsafeRawPointer) {
        if let error = error {
            NSLog(error.localizedDescription)
            self.renderIndicatorView?.finishAnimation(SaveImageHandlerError.failed.message)
            self.showAppSettingsDialog()
            return
        }
        self.renderIndicatorView?.finishAnimation(SaveImageHandlerError.success.message)
    }

    static private func willPrepareImage(_ view: UIView, rect: CGRect,
                                         completionHandler: @escaping () -> Void) -> UIImage? {
        let image = UIImage.imageWithView(view).toPNG()
        completionHandler()
        guard let image = image?.crop(rect, sizeView: view.frame.size) else { return nil }
        guard let image = image.toPNG() else { return nil }
        return image
    }

    static private func showIndicator(with message: String) {
        DispatchQueue.main.async {
            guard let window = UIApplication.window else { return }
            self.renderIndicatorView = RenderIndicatorView(frame: window.frame, message: message)
        }
    }

    static private func showAppSettingsDialog() {
        AuthorizationAssests.openAppSettings(
            "Allow Access to Your Photos",
            message: "This lets you save your Wallshapes arts into Photos.",
            titleOK: "Open Settings"
        )
    }
}
