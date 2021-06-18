//
//  WallshapeView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

final class WallshapeView: UIView {
    private var wallshapeViewControl: WallshapeViewControl?
    private var gesturesControl: ShapeGesturesControl?
    private var menuShapeControl: MenuShapeControl?
    internal var contentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView = UIView(frame: frame)
        self.menuShapeControl = MenuShapeControl()
        self.wallshapeViewControl = WallshapeViewControl(self, menuControl: menuShapeControl)
        self.gesturesControl = ShapeGesturesControl(self)
        self.backgroundColor = .init(white: 0.15, alpha: 1)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func chooseColors(_ count: Int) {
        wallshapeViewControl?.chooseColors(count)
    }

    public func chooseColor() {
        wallshapeViewControl?.chooseColor()
    }

    public func resizeContentView() {
        wallshapeViewControl?.resizeContentView()
    }

    public func gridView() {
        wallshapeViewControl?.gridView()
    }

    public func addShape() {
        wallshapeViewControl?.addShape()
    }

    public func clearShapes() {
        wallshapeViewControl?.clearShapes()
    }

    public func saveFile() {
        wallshapeViewControl?.saveFile()
    }

    public func saveToPhotos(title: String) {
        wallshapeViewControl?.saveToPhotos(title: title)
    }

    public func hideMenu() {
        menuShapeControl?.hideMenuShape()
    }
}

extension WallshapeView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
                            -> Bool {
        if gestureRecognizer is UILongPressGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}
