//
//  ShapeMenuView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 6/18/21.
//

import UIKit

final class ShapeMenuView: CustomMenuDelegate {
    
    enum ShapeMenuTypeEnum: String, CaseIterable {
        case circle = "circle",
             square = "square-of-rounded-corners",
             triangle = "bleach",
             polygon = "hexagonal",
             none = ""
    }
    
    typealias EnumType = ShapeMenuTypeEnum

    static func allCases() -> [EnumType] {
        return EnumType.allCases.filter {!extraCases().contains($0) && $0 != .none}
    }
    
    static func extraCases() -> [EnumType] { return []}

    static func imageNameBy(_ type: EnumType) -> String {
        return type.rawValue
    }

    static func state(_ type: EnumType) -> UIControl.State {
        switch type {
        case .circle, .square, .triangle:
            return .highlighted
        case .polygon:
            return .selected
        case .none:
            return .normal
        }
    }
}
