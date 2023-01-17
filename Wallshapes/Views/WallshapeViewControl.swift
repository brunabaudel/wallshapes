//
//  WallshapeViewControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/20/21.
//

import UIKit

final class WallshapeViewControl {
    private weak var wallshapeview: WallshapeView?
    private weak var menuShapeControl: MenuShapeControl?
    private weak var menuNavControl: MenuNavControl?
    private var modelControl: ModelControl?

    init(_ wallshapeView: WallshapeView, with wallshape: Wallshape, menuShapeControl: MenuShapeControl, menuNavControl: MenuNavControl) {
        self.wallshapeview = wallshapeView
        self.modelControl = ModelControl()
        self.menuShapeControl = menuShapeControl
        self.menuNavControl = menuNavControl
        
        self.initWallshape(with: wallshape)
    }
    
    private func initWallshape(with wallshape: Wallshape) {
        wallshape.fileName = wallshape.fileName == "" ? UUID().uuidString : wallshape.fileName
        initContentView(with: wallshape)
        initShapes(with: wallshape)
        initSelectView()
    }

    private func initShapes(with wallshape: Wallshape) {
        guard let view = self.wallshapeview else { return }
        for shape in wallshape.shapes {
            let shapeView = ShapeView(shape: shape)
            menuShapeControl?.createShapeView(shapeView)
            view.addSubview(shapeView)
        }
    }

    private func initContentView(with wallshape: Wallshape) {
        guard let view = self.wallshapeview else { return }
        guard let contentView = view.contentView else { return }
        if wallshape.backgroundColors.count == 1 {
            contentView.backgroundColor = wallshape.backgroundColors.first
        } else {
            addGradientLayer(with: wallshape.backgroundColors)
        }
        view.addSubview(contentView)
    }

    private func initSelectView() {
        guard let view = self.wallshapeview,
              let selectBorder = view.selectBorder,
              let tempView = view.tempView else { return }
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineDashPattern = [3, 3]
        shapeLayer.lineWidth = 2
        shapeLayer.strokeColor = UIColor.white.cgColor
        selectBorder.frame = CGRect.zero
        selectBorder.backgroundColor = .clear
        selectBorder.isHidden = true
        selectBorder.layer.addSublayer(shapeLayer)
        tempView.addSubview(selectBorder)
        view.addSubview(tempView)
    }

    // MARK: - Colors

    private func addGradientLayer(with colors: [UIColor]) {
        let gradientLayer = initGradientLayer(colors)
        self.wallshapeview?.contentView?.layer.sublayers?.removeAll(where: { layer in layer is CAGradientLayer })
        self.wallshapeview?.contentView?.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func initGradientLayer(_ colors: [UIColor]) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        let cgColors = colors.map {$0.cgColor}
        gradientLayer.frame = self.wallshapeview?.contentView?.bounds ?? CGRect.zero
        gradientLayer.colors = cgColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }

    // MARK: - Navigationbar Functions

    public func addShape() {
        guard let view = self.wallshapeview,
              let menuShapeControl = self.menuShapeControl else { return }
        menuShapeControl.showMenu()
        menuNavControl?.hideMenu()
        let size = view.bounds.width > view.bounds.height ? view.bounds.midY/2 : view.bounds.midX/2
        let shape = Shape()
        shape.frame = CGRect(x: size*1.75, y: size, width: size, height: size)
        shape.type = ShapeType.circle
        shape.layerColors?.append(UIColor.random)
        shape.layerColors?.append(UIColor.random)
        let shapeView = ShapeView(shape: shape)
        menuShapeControl.createShapeView(shapeView)
        menuShapeControl.unselectShapeView()
        menuShapeControl.selectShapeView(shapeView)
    }

    public func menuColor() {
        menuShapeControl?.unselectShapeView()
        menuShapeControl?.hideMenu()
        menuNavControl?.showMenu()
    }
    
    public func cancel(completion: @escaping () -> Void) {
        hideMenu()
        completion()
    }
    
    public func hideMenu() {
        menuShapeControl?.hideMenu()
        menuNavControl?.hideMenu()
    }

    // MARK: - Save file

    public func saveFile(wallshape: Wallshape, completion: (() -> Void)? = {}) {
        modelControl?.updateBackgroundColors(backgroundUIColors())
        modelControl?.addShapeViews(subShapeViews())
        modelControl?.save(wallshape: wallshape)
        hideMenu()
        (completion ?? {})()
    }
    
    public func saveFileAndThumbnail(wallshape: Wallshape, completion: (() -> Void)? = {}) {
        self.saveThumbnail(fileName: wallshape.fileName)
        self.saveFile(wallshape: wallshape, completion: completion)
        hideMenu()
    }

    public func saveToPhotos(wallshape: Wallshape, message: String, completion: @escaping () -> Void) {
        guard let view = self.wallshapeview,
              let contentView = view.contentView,
              let selectedBorder = view.selectBorder,
              let isSelected = view.isSelected else {return}
        selectedBorder.isHidden = true
        hideMenu()
        SaveImage.save(wallshape.fileName, message: message, view: view, frame: contentView.frame) {
            if isSelected { selectedBorder.isHidden = false }
        }
    }
    
    public func delete(wallshape: Wallshape, completion: @escaping () -> Void) {
        FileControl.deleteFiles(fileName: wallshape.fileName, exts: "json", "png") {
            self.hideMenu()
            completion()
        }
    }
    
    public func rename(wallshape: Wallshape, completion: @escaping () -> Void) {
        FileControl.deleteFiles(fileName: wallshape.fileName, exts: "json") {
            self.saveFile(wallshape: wallshape)
        }
    }
    
    public func createImage(fileName: String) -> UIImage? {
        guard let view = self.wallshapeview,
              let contentView = view.contentView,
              let selectedBorder = view.selectBorder,
              let isSelected = view.isSelected else {return nil}
        selectedBorder.isHidden = true
        let image = SaveImage.createImage(view: view, rect: contentView.frame)
        if isSelected { selectedBorder.isHidden = false }
        return image
    }
    
    private func saveThumbnail(fileName: String) {
        let image = self.createImage(fileName: fileName)
        guard let thumbmnail = image?.preparingThumbnail(of: CGSize(width: 80, height: 220))?.toData() else { return }
        FileControl.write(thumbmnail, fileName: fileName, ext: "png")
    }

    private func subShapeViews() -> [ShapeView] {
        guard let view = self.wallshapeview,
              let menuShapeControl = self.menuShapeControl else {return []}
        menuShapeControl.unselectShapeView()
        let shapeViews = view.subviews
            .filter {
                if let shapeview = $0 as? ShapeView {
                    shapeview.shape?.frame = shapeview.frame
                    return true
                }
                return false
            }
            .compactMap { $0 as? ShapeView }
        return shapeViews
    }

    private func backgroundUIColors() -> [UIColor] {
        if let sublayer = self.wallshapeview?.contentView?.firstSublayer,
           let gradientLayer = sublayer as? CAGradientLayer,
           let colors = gradientLayer.colors,
           let cgColors = colors as? [CGColor] {
            return cgColors.map {UIColor(cgColor: $0)}
        }
        if let uicolors = self.wallshapeview?.contentView?.backgroundColor {
            return [uicolors]
        }
        return []
    }
}
