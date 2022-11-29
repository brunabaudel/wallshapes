//
//  ArrangeMenuView.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 5/22/21.
//

import UIKit

enum ArrangeMenuTypeEnum: Int, IntegerProtocol {
    case bringToFront, sendToBack, bringForward, sendBackward
}

final class ArrangeMenuView: CustomMenuDelegate {
    typealias EnumType = ArrangeMenuTypeEnum

    static private let typeImage = [EnumType.bringToFront: "bring-front",
                                    .sendToBack: "send-back",
                                    .bringForward: "bring-forward",
                                    .sendBackward: "send-backward"
                                    ]

    static func allCases() -> [EnumType] {
        return (typeImage.map {$0.key}).sorted { $0.rawValue < $1.rawValue }
    }

    static func imageNameBy(_ type: EnumType) -> String {
        return typeImage[type] ?? ""
    }

    static func state(_ type: EnumType) -> UIControl.State {
        return .highlighted
    }
}
