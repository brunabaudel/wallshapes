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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.wallshapeViewControl = WallshapeViewControl(self)
        self.gesturesControl = ShapeGesturesControl(self)
        self.backgroundColor = .init(white: 0.15, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func contentViewFrame() -> CGRect {
        return wallshapeViewControl?.contentViewFrame() ?? CGRect.zero
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

    public func addShape() {
        wallshapeViewControl?.addShape()
    }

    public func clearShapes() {
        wallshapeViewControl?.clearShapes()
    }
    
    public func saveFile() {
        wallshapeViewControl?.saveFile()
    }
    
    public func hideMenuShape() {
        wallshapeViewControl?.hideMenuShape()
    }
}

extension WallshapeView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
            -> Bool {
        return true
    }
}
