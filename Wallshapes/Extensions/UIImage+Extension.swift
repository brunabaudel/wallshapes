//
//  UIImage+Extension.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

extension UIImage {
    class func imageWithView(_ view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }
    }

    func configIconColor(_ color: UIColor) -> UIImage? {
        if #available(iOS 13.0, *) {
            return withTintColor(color, renderingMode: .alwaysOriginal)
        }
        return tinted(with: color)
    }

    func tinted(with color: UIColor) -> UIImage? {
        return UIGraphicsImageRenderer(size: size).image { _ in
            color.setFill()
            withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
    }

    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    func toPNG() -> UIImage? {
        if let imageData = self.pngData() {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func toData() -> Data? {
        if let data = self.pngData() {
            return data
        }
        return nil
    }

    func crop(_ cropRect: CGRect, sizeView: CGSize) -> UIImage? {
        let imageViewScale = max(self.size.width / sizeView.width, self.size.height / sizeView.height)

        let cropZone = CGRect(x: cropRect.origin.x * imageViewScale,
                              y: cropRect.origin.y * imageViewScale,
                              width: cropRect.size.width * imageViewScale,
                              height: cropRect.size.height * imageViewScale)

        guard let cutImageRef = self.cgImage?.cropping(to: cropZone) else {return nil}
        return UIImage(cgImage: cutImageRef)
    }
}
