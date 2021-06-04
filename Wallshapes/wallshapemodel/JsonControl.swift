//
//  JsonControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/16/21.
//

import Foundation

final class JsonControl {
    static func decodeParse<T: Decodable>(url: URL?, type: T.Type) -> T? {
        guard let url = url, let object = type.decodeParse(url: url) else { return nil }
        return object
    }

    static func encodeParse<T: Encodable>(object: T) -> Data? {
        return object.encodeParse()
    }
}
