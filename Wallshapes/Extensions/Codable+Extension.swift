//
//  Codable+Extension.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/16/21.
//

import Foundation

extension Decodable {
    static func decodeParse(url: URL?) -> Self? {
        do {
            guard let url = url else { return nil }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(self, from: data)
        } catch {
            NSLog(error.localizedDescription)
        }
        return nil
    }
}

extension Encodable {
    func encodeParse() -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(self)
        } catch {
            NSLog(error.localizedDescription)
        }
        return nil
    }
}
