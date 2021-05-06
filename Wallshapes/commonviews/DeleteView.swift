//
//  DeleteView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 5/5/21.
//

import UIKit

class DeleteView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    private func initView() {
        backgroundColor = .clear
        alpha = 0.0
        layer.contents = UIImage(named: "trash")?.cgImage
    }
    
    public func toggle(_ isHidden: Bool, completion: ((Bool) -> Void)? = nil) {
        if !isHidden {
            self.fadeOut(0.4, completion)
        } else {
            self.fadeIn(0.4, completion)
        }
    }
}
