//
//  SlideMenu.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

enum SliderType {
    case shadow, alpha
}

class SliderMenu: UISlider {
    public var type: SliderType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
