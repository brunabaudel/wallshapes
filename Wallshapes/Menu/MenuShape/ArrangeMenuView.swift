//
//  ArrangeMenuView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 5/22/21.
//

import UIKit

final class ArrangeMenuView: CustomMenuDelegate {
    enum ArrangeMenuTypeEnum: String, CaseIterable {
        case bringToFront = "bring-front",
             sendToBack = "send-back",
             bringForward = "bring-forward",
             sendBackward = "send-backward",
             none = ""
    }

    typealias EnumType = ArrangeMenuTypeEnum

    static func allCases() -> [EnumType] {
        return EnumType.allCases.filter {!extraCases().contains($0) && $0 != .none}
    }
    
    static func extraCases() -> [EnumType] { return []}

    static func imageNameBy(_ type: EnumType) -> String {
        return type.rawValue
    }

    static func state(_ type: EnumType) -> UIControl.State {
        return .highlighted
    }
}
