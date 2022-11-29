//
//  SaveImageHandlerError.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/15/21.
//

import Foundation

public enum SaveImageHandlerError {
    case success
    case failed
    case unknown

    var title: String {
        return "Photo Save Error"
    }

    var message: String {
        switch self {
        case .success:
            return "Image saved"
        case .failed:
            return "Image not saved"
        case .unknown:
            return "An unknown error occured."
        }
    }
}
