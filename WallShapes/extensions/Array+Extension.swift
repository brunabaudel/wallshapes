//
//  Array+Extension.swift
//  WallShapes
//
//  Created by Bruna Baudel on 3/1/21.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}
