//
//  UIImage+Extension.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

extension UIImage {
//    func ciblur(forRect rect: CGRect, with radius: Double) -> UIImage? {
//        let context = CIContext(options: nil)
//        let inputImage = CIImage(cgImage: self.cgImage!)
//
//        let filter = CIFilter(name: "CIGaussianBlur")
//        filter?.setValue(inputImage, forKey: kCIInputImageKey)
//        filter?.setValue(radius, forKey: kCIInputRadiusKey)
//
//        guard let outputImage = filter?.outputImage,
//              let cgImage = context.createCGImage(outputImage, from: rect)
//        else {
//            return nil
//        }
//        return UIImage(cgImage: cgImage)
//    }
    
    class func imageWithView(_ view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { ctx in
            view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
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
        guard let imageData = pngData() else {return nil}
        guard let imagePng = UIImage(data: imageData) else {return nil}
        return imagePng
    }
    
    func crop(_ cropRect: CGRect, sizeView: CGSize) -> UIImage? {
        let imageViewScale = max(self.size.width / sizeView.width, self.size.height / sizeView.height)

        let cropZone = CGRect(x: cropRect.origin.x * imageViewScale, y: cropRect.origin.y * imageViewScale,
                              width: cropRect.size.width * imageViewScale, height: cropRect.size.height * imageViewScale)

        guard let cutImageRef = self.cgImage?.cropping(to: cropZone) else {return nil}
        return UIImage(cgImage: cutImageRef)
    }
}
