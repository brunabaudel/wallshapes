//
//  MainMenuView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 5/28/21.
//

import UIKit

enum MainMenuTypeEnum: String, CaseIterable {
    case clone = "copy",
         shapes = "shapes",
         color = "bucket",
         shadow = "shadow",
         transparency = "transparency",
         arrangeSet = "arrange-set",
         delete = "trash",
         none = ""
}

final class MainMenuView: CustomMenuDelegate {
    typealias EnumType = MainMenuTypeEnum

    static func allCases() -> [EnumType] {
        return EnumType.allCases.filter {!extraCases().contains($0) && $0 != .none}
    }
    
    static func extraCases() -> [EnumType] {
        return [.delete]
    }

    static func imageNameBy(_ type: EnumType) -> String {
        return type.rawValue
    }

    static func state(_ type: EnumType) -> UIControl.State {
        switch type {
        case .clone, .delete:
            return .highlighted
        case .shapes, .shadow, .transparency, .arrangeSet, .color:
            return .selected
        case .none:
            return .normal
        }
    }
}
