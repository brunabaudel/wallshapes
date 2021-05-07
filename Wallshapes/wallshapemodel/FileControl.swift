//
//  FileControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/18/21.
//

import Foundation

final class FileControl {
    static func write(url: URL?, content: String) {
        do {
            guard let url = url else { return }
            try content.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
    static func read(url: URL?) -> String {
        do {
            guard let url = url else { return "" }
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            NSLog(error.localizedDescription)
        }
        return ""
    }
    
    static func copyToDocuments(fileName: String, ext: String) {
        guard let documentsURL = findURL(fileName: fileName, ext: ext) else { return }
        guard let sourceURL = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            NSLog("Source File not found.")
            return
        }
        do {
            if !FileManager.default.fileExists(atPath: documentsURL.path) {
                try FileManager.default.copyItem(at: sourceURL, to: documentsURL)
            }
        } catch {
            NSLog("Unable to copy file")
        }
    }
    
    static func findURL(fileName: String, ext: String) -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let url = dir.appendingPathComponent(fileName).appendingPathExtension(ext)
        return url
    }
}
