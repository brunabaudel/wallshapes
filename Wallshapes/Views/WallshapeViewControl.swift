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
    private var modelControl: ModelControl?

    init(_ wallshapeView: WallshapeView, wih wallshape: Wallshape, menuControl: MenuShapeControl) {
        self.wallshapeview = wallshapeView
        self.modelControl = ModelControl()
        self.menuShapeControl = menuControl
        
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
        if wallshape.size == .small {
            resizeContentView()
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
        self.initDeleteButton()
    }

    private func initDeleteButton() {
        guard let view = self.wallshapeview,
              let selectedBorder = view.selectBorder,
              let btndelete = view.btndelete else { return }
        btndelete.translatesAutoresizingMaskIntoConstraints = false
        btndelete.addTarget(self, action: #selector(deleteShapeView(_:)), for: .touchUpInside)
        btndelete.setImage(UIImage(named: "remove"), for: .normal)
        btndelete.isHidden = true
        selectedBorder.addSubview(btndelete)

        btndelete.centerXAnchor.constraint(equalTo: selectedBorder.centerXAnchor).isActive = true
        btndelete.centerYAnchor.constraint(equalTo: selectedBorder.centerYAnchor).isActive = true
        btndelete.heightAnchor.constraint(equalTo: selectedBorder.heightAnchor, multiplier: 0.4).isActive = true
        btndelete.widthAnchor.constraint(equalTo: selectedBorder.widthAnchor, multiplier: 0.4).isActive = true
    }

    // MARK: - Colors

    public func chooseColors(_ count: Int) {
        let colors = self.randomColors(2)
        guard let gradientLayer = (self.wallshapeview?.contentView?.firstSublayer) as? CAGradientLayer else {
            addGradientLayer(with: colors)
            return
        }
        let cgColors = colors.map {$0.cgColor}
        gradientLayer.colors = cgColors
    }

    public func chooseColor() {
        let color = UIColor.random
        self.wallshapeview?.contentView?.layer.sublayers?.removeAll(where: { layer in layer is CAGradientLayer })
        self.wallshapeview?.contentView?.backgroundColor = color
    }

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

    private func randomColors(_ count: Int = 2) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<count {
            let color = UIColor.random
            if !colors.contains(color) {
                colors.append(color)
            }
        }
        return colors
    }

    // MARK: - Navigationbar Functions

    public func deleteShapeViews(_ isActive: Bool) {
        guard let view = self.wallshapeview,
              let menu = self.menuShapeControl,
              let tempview = view.tempView,
              let selectedBorder = view.selectBorder,
              let btndelete = view.btndelete else {return}
        btndelete.isHidden = !isActive
        view.isDeleteActive = isActive
        guard let isDeleteActive = view.isDeleteActive else {return}
        if isDeleteActive {
            menu.hideMenu()
            if (tempview.subviews.filter {type(of: $0) == ShapeView.self}).count > 0 {
                view.selectedIndex = view.subviews.firstIndex(of: tempview)
                view.insertSubview(tempview, at: view.subviews.count)
                return
            }
            let shapeview = (view.subviews.filter {type(of: $0) == ShapeView.self}).last
            if let shapeview = shapeview as? ShapeView {
                menu.selectShapeView(shapeview)
            }
        } else {
            if !selectedBorder.isHidden {menu.showMenu()}
            guard let index = view.selectedIndex else {return}
            view.insertSubview(tempview, at: index)
        }
    }

    @objc private func deleteShapeView(_ sender: UIButton) {
        guard let view = self.wallshapeview, let tempview = view.tempView,
              let menu = self.menuShapeControl else {return}
        tempview.subviews.forEach {
            if type(of: $0) == ShapeView.self {
                menu.unselectShapeView()
                menu.hideMenu()
                $0.removeFromSuperview()
            }
        }
    }

    public func resizeContentView() {
        guard let view = self.wallshapeview, let contentView = view.contentView else { return }
        var newSize: CGRect = view.frame
        if contentView.frame.height != contentView.frame.width {
            newSize = CGRect(origin: CGPoint.zero, size: self.squaredSize())
        }
        contentView.frame.origin = CGPoint.zero
        contentView.frame.size = newSize.size
        contentView.center = view.center
        CATransaction.removeAnimation {
            contentView.firstSublayer?.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        }
    }

    private func squaredSize() -> CGSize {
        guard let view = self.wallshapeview else { return CGSize.zero }
        let frame = min(view.frame.height, view.frame.width)
        return CGSize(width: frame/1.2, height: frame/1.2)
    }

    public func addShape() {
        guard let view = self.wallshapeview,
              let menuShapeControl = self.menuShapeControl else { return }
        menuShapeControl.showMenu()
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

    public func clearShapes() {
        guard let view = self.wallshapeview else { return }
        view.subviews.forEach { if type(of: $0) == ShapeView.self { $0.removeFromSuperview() } }
        view.tempView?.subviews.forEach {
            if type(of: $0) == ShapeView.self { $0.removeFromSuperview() }
            $0.isHidden = true
        }
        menuShapeControl?.hideMenu()
    }

    // MARK: - Save file

    public func saveFile(wallshape: Wallshape) {
        modelControl?.wallshapeSize(contentViewSize())
        modelControl?.updateBackgroundColors(backgroundUIColors())
        modelControl?.addShapeViews(subShapeViews())
        modelControl?.save(wallshape: wallshape)
        menuShapeControl?.hideMenu()
    }

    public func saveToPhotos(name: String, message: String, completion: @escaping () -> Void) {
        guard let view = self.wallshapeview,
              let contentView = view.contentView,
              let selectedBorder = view.selectBorder,
              let isSelected = view.isSelected else {return}
        selectedBorder.isHidden = true
        SaveImage.save(name, message: message, view: view, frame: contentView.frame) {
            if isSelected { selectedBorder.isHidden = false }
            completion()
        }
    }

    private func contentViewSize() -> WallshapeSize {
        guard let view = self.wallshapeview else { return .normal }
        if view.contentView?.frame.height ?? 0 < view.frame.height {
            return .small
        }
        return .normal
    }

    private func subShapeViews() -> [ShapeView] {
        guard let view = self.wallshapeview,
              let tempview = view.tempView,
              let index = view.selectedIndex else {return []}
        let shapeView = (tempview.subviews.filter {type(of: $0) == ShapeView.self}).first
        var shapeViews = view.subviews
            .filter {
                if let shapeview = $0 as? ShapeView {
                    shapeview.shape?.frame = shapeview.frame
                    return true
                }
                return false
            }
            .compactMap { $0 as? ShapeView }
        if let shapeview = shapeView as? ShapeView {
            shapeview.shape?.frame = tempview.frame
            shapeViews.insert(shapeview, at: index - 1)
        }
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
