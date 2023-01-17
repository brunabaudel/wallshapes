//
//  FileControl.swift
//  Wallshapes
//
//  Created by Bruna Baudel on 4/18/21.
//

import Foundation

final class FileControl {
    
    static private let nameFolder = "Wallshapes"
    
    static private var documentDirectoryURL: URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            NSLog("Unable to find the document directory")
            return nil
        }
        print(dir)
        return dir
    }
    
    static func write(_ content: String, fileName: String, ext: String) {
        guard let url = findURL(fileName: fileName, ext: ext) else {
            NSLog("Unable to find the directory")
            return
        }
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
    static func write(_ data: Data, fileName: String, ext: String) {
        guard let url = findURL(fileName: fileName, ext: ext) else {
            NSLog("Unable to find the directory")
            return
        }
        do {
            try data.write(to: url)
        } catch {
            NSLog("Unable to Write Image Data to Disk")
        }
    }

    static func read(fileName: String, ext: String) -> String {
        guard let url = findURL(fileName: fileName, ext: ext) else {
            NSLog("Unable to find the directory")
            return ""
        }
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            NSLog(error.localizedDescription)
        }
        return ""
    }

    static func deleteFiles(fileName: String, exts: String..., completion: @escaping () -> Void = {}) {
        for ext in exts {
            guard let url = findURL(fileName: fileName, ext: ext) else {
                NSLog("Unable to find the directory")
                return
            }
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(atPath: url.path)
                    completion()
                } catch {
                    NSLog("Could not delete file, probably read-only filesystem")
                }
            } else {
                completion()
            }
        }
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
        return documentDirectoryURL?.appendingPathComponent(nameFolder).appendingPathComponent(fileName).appendingPathExtension(ext)
    }
    
    static func findAllURLs() -> [URL] {
        do {
            createDirectory()
            return try FileManager.default.contentsOfDirectory(at: documentDirectoryURL?.appendingPathComponent(nameFolder) ?? URL(fileURLWithPath: ""),
                                                               includingPropertiesForKeys: nil)
        } catch {
            NSLog("Unable to find the directory")
        }
        return []
    }
    
    static func createDirectory() {
        do {
            if !FileManager.default.fileExists(atPath: documentDirectoryURL?.appendingPathComponent(nameFolder).path ?? "") {
                try FileManager.default.createDirectory(at: documentDirectoryURL?.appendingPathComponent(nameFolder) ??  URL(fileURLWithPath: ""), withIntermediateDirectories: false)
            }
        } catch {
            NSLog("Unable to create the directory")
        }
    }
}