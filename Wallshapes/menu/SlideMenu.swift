//
//  SlideMenu.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

enum SliderType {
    case shadow, alpha, polygon
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
