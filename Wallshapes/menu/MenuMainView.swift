//
//  MenuMainView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 5/28/21.
//

import UIKit

enum MenuMainTypeEnum: Int, IntegerProtocol {
    case clone, circle, square, triangle, polygon, gradient,
         plainColor, shadow, transparency, arrangeSet
}

final class MenuMainView: CustomMenuDelegate {
    typealias EnumType = MenuMainTypeEnum
    
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
        return (typeImage.map {$0.key}).sorted { o, i in o.rawValue < i.rawValue }
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
