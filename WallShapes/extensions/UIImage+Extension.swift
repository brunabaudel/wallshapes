//
//  UIImage+Extension.swift
//  WallShapes
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
    
    class func configIcon(with sfSymbol: String) -> UIImage? {
        if #available(iOS 13.0, *) {
            let largeConfig = SymbolConfiguration(pointSize: 23, weight: .light, scale: .medium)
            return UIImage(systemName: sfSymbol, withConfiguration: largeConfig)
        }
        return UIImage(named: "stop") //TODO!
    }
    
    func configIconColor(_ color: UIColor) -> UIImage? {
        if #available(iOS 13.0, *) {
            return withTintColor(color, renderingMode: .alwaysOriginal)
        }
        return UIImage(named: "stop") //TODO!
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
}
