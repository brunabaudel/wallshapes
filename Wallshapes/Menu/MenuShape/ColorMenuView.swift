//
//  ColorMenuView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 14/01/2023.
//

import UIKit

final class ColorMenuView: CustomMenuDelegate {
    enum ColorMenuTypeEnum: String, CaseIterable {
        case plain = "plain",
             gradient1 = "gradient1",
             gradient2 = "gradient2",
             none = ""
    }
    
    typealias EnumType = ColorMenuTypeEnum
    
    static func allCases() -> [EnumType] {
        return EnumType.allCases.filter {!extraCases().contains($0) && $0 != .none}
    }
    
    static func extraCases() -> [EnumType] { return [.plain]}

    static func imageNameBy(_ type: EnumType) -> String {
        return type.rawValue
    }

    static func state(_ type: EnumType) -> UIControl.State {
        return .highlighted
    }
}
