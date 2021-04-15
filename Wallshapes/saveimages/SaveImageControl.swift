//
//  SaveImage.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/10/21.
//

import UIKit

class SaveImage: NSObject {
    private var renderIndicatorView: RenderIndicatorView!
    
    func save(_ title: String, view: RandomGradientView) {
        AuthorizationAssests().authorization() { authorized in
            if authorized {
                DispatchQueue.main.async {
                    let frame = view.randomBackground().frame
                    self.willSaveImage(title, view: view, rect: frame)
                }
            } else {
                AuthorizationAssests().openAppSettings(
                    "Permission required",
                    message: "You have to give permission to ssave on Photo Library.",
                    titleOK: "Go to settings")
            }
        }
    }
    
    private func willSaveImage(_ title: String, view: UIView, rect: CGRect) {
        self.showIndicator(with: title)
        guard let image = self.willPrepareImage(view, rect: rect) else {
            self.renderIndicatorView.finishAnimation(SaveImageHandlerError.failed.message)
            return
        }
        self.writeToPhotoAlbum(image)
    }
    
    private func writeToPhotoAlbum(_ image: UIImage) {
       UIImageWriteToSavedPhotosAlbum(image, self, #selector(writeToPhotoAlbumHandler), nil)
   }

    @objc private func writeToPhotoAlbumHandler(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            self.renderIndicatorView.finishAnimation(SaveImageHandlerError.failed.message)
            return
        }
        self.renderIndicatorView.finishAnimation(SaveImageHandlerError.success.message)
    }
    
    private func willPrepareImage(_ view: UIView, rect: CGRect) -> UIImage? {
        let image = UIImage.imageWithView(view).toPNG()
        guard let croppedImage = image?.crop(rect, sizeView: view.frame.size) else { return nil }
        guard let pngImage = croppedImage.toPNG() else { return nil }
        return pngImage
    }
    
    private func showIndicator(with message: String) {
        DispatchQueue.main.async {
            guard let window = UIApplication.window else { return }
            self.renderIndicatorView = RenderIndicatorView(frame: window.frame, message: message)
        }
    }
}
