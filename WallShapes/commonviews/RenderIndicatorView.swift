//
//  RenderIndicatorView.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/15/21.
//

import UIKit

class RenderIndicatorView: UIView {
    var spinner: UIActivityIndicatorView!
    var labelSpinner: UILabel!
    var label: UILabel!
    
    init(frame: CGRect, message: String) {
        super.init(frame: frame)
        initView()
        initSpinner(with: message)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initView() {
        backgroundColor = .init(white: 0.3, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    private func initSpinner(with message: String) {
        self.spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8).isActive = true
        initLabelSpinner(message)
    }
    
    private func initLabelSpinner(_ message: String) {
        self.labelSpinner = UILabel()
        labelSpinner.translatesAutoresizingMaskIntoConstraints = false
        labelSpinner.text = message
        labelSpinner.textColor = .white
        labelSpinner.numberOfLines = 0
        addSubview(labelSpinner)
        labelSpinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        labelSpinner.topAnchor.constraint(equalTo: spinner.bottomAnchor).isActive = true
    }
    
    private func initFinishLabel(with message: String) {
        self.label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.textColor = .white
        label.numberOfLines = 0
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    public func finishAnimation(_ message: String) {
        spinner.removeFromSuperview()
        labelSpinner.removeFromSuperview()
        initFinishLabel(with: message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.removeFromSuperview()
        }
    }
}
