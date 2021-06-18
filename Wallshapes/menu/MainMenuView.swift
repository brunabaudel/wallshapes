//
//  MainMenuView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 5/28/21.
//

import UIKit

enum MainMenuTypeEnum: Int, IntegerProtocol {
    case clone, circle, square, triangle, polygon, gradient,
         plainColor, shadow, transparency, arrangeSet
}

final class MainMenuView: CustomMenuDelegate {
    typealias EnumType = MainMenuTypeEnum

    static private let typeImage = [EnumType.clone: "copy",
                                    .circle: "circle",
                                    .square: "square-of-rounded-corners",
                                    .triangle: "bleach",
                                    .gradient: "gradient",
                                    .plainColor: "bucket",
                                    .shadow: "shadow",
                                    .transparency: "transparency",
                                    .polygon: "hexagonal",
                                    .arrangeSet: "arrange-set"
                                    ]

    static func allCases() -> [EnumType] {
        return (typeImage.map {$0.key}).sorted {$0.rawValue < $1.rawValue}
    }

    static func imageNameBy(_ type: EnumType) -> String {
        return typeImage[type] ?? ""
    }

    static func state(_ type: EnumType) -> UIControl.State {
        switch type {
        case .clone, .circle, .square, .triangle, .gradient, .plainColor:
            return .highlighted
        case .shadow, .transparency, .polygon, .arrangeSet:
            return .selected
        }
    }
}
