//
//  StackView.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import UIKit

class StackView: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addSubviews() {
    }
}
