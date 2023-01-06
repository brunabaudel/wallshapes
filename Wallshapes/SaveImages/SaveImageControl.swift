//
//  SaveImage.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/10/21.
//

import UIKit

final class SaveImage: NSObject {
    private static var renderIndicatorView: RenderIndicatorView?
    private static var completion: () -> Void = {}

    static public func save(_ name: String, message: String, view: UIView, frame: CGRect,
                            completion: @escaping () -> Void) {
        self.completion = completion
        self.willSaveImage(name, message: message, view: view, rect: frame)
    }

    static private func willSaveImage(_ name: String, message: String, view: UIView, rect: CGRect) {
        self.showIndicator(with: message)
        guard let image = self.willPrepareImage(view, rect: rect) else {
            self.renderIndicatorView?.finishAnimation(SaveImageHandlerError.failed.message, competionHandler: completion)
            return
        }
        self.createThumbnail(image: image, name: name)
        self.writeToPhotoAlbum(image)
    }

    static private func writeToPhotoAlbum(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(writeToPhotoAlbumHandler), nil)
   }

    @objc static private func writeToPhotoAlbumHandler(_ image: UIImage, didFinishSavingWithError error: Error?,
                                                       contextInfo: UnsafeRawPointer) {
        if let error = error {
            NSLog(error.localizedDescription)
            self.renderIndicatorView?.finishAnimation(SaveImageHandlerError.failed.message, competionHandler: completion)
            self.showAppSettingsDialog()
            return
        }
        self.renderIndicatorView?.finishAnimation(SaveImageHandlerError.success.message, competionHandler: completion)
    }

    static private func willPrepareImage(_ view: UIView, rect: CGRect) -> UIImage? {
        let image = UIImage.imageWithView(view).toPNG()
        guard let imagecropped = image?.crop(rect, sizeView: view.frame.size) else { return nil }
        guard let imagepng = imagecropped.toPNG() else { return nil }
        return imagepng
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
    
    static private func createThumbnail(image: UIImage, name: String) {
        guard let thumbmnail = image.preparingThumbnail(of: CGSize(width: 80, height: 220))?.toData() else { return }
        FileControl.write(thumbmnail, fileName: name, ext: "png")
    }
}
