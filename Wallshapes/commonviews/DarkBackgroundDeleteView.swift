//
//  DarkBackgroundDeleteView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 5/6/21.
//

import UIKit

class DarkBackgroundDeleteView: UIView {
    
    public var index: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    private func initView() {
        backgroundColor = .init(white: 0.1, alpha: 0.7)
        alpha = 0.0
    }
    
    public func toggle(_ isHidden: Bool, completion: ((Bool) -> Void)? = nil) {
        if !isHidden {
            self.fadeOut(0.4, completion)
        } else {
            self.fadeIn(0.4, completion)
        }
    }
}
