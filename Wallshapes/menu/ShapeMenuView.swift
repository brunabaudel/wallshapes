//
//  ShapeMenuView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 6/18/21.
//

import UIKit

enum ShapeMenuTypeEnum: Int, IntegerProtocol {
    case circle, square, triangle, polygon
}

final class ShapeMenuView: CustomMenuDelegate {
    typealias EnumType = ShapeMenuTypeEnum

    static private let typeImage = [EnumType.circle: "circle",
                                    .square: "square-of-rounded-corners",
                                    .triangle: "bleach",
                                    .polygon: "hexagonal"
                                    ]

    static func allCases() -> [EnumType] {
        return (typeImage.map {$0.key}).sorted { $0.rawValue < $1.rawValue }
    }

    static func imageNameBy(_ type: EnumType) -> String {
        return typeImage[type] ?? ""
    }

    static func state(_ type: EnumType) -> UIControl.State {
        switch type {
        case .circle, .square, .triangle:
            return .highlighted
        case .polygon:
            return .selected
        }
    }
}
