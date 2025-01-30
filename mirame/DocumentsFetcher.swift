//
//  DocumentsFetcher.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/2/21.
//  Copyright © 2021 Trey Tartt. All rights reserved.
//

import Foundation
import SneakyCamPackage

class DocumentsFetcher {
    static func readFiles() -> DocumentFiles {
        let docFiles = DocumentFiles()
        do{
            let dir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            for location in FaceNodeLocation.allCases {
                let subDir = dir.appendingPathComponent(location.rawValue, isDirectory: true)
                if !FileManager.default.fileExists(atPath: subDir.path)  {
                    try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true, attributes: nil)
                }
                let directoryContents = try FileManager.default.contentsOfDirectory(at: subDir, includingPropertiesForKeys: nil)
                let files = directoryContents.filter{ $0.pathExtension == "png" }
                var fileInfos = [FileInfo]()
                files.forEach({ file in
                    let fileName = file.deletingPathExtension().lastPathComponent
                    fileInfos.append((fileName, file))
                })
                docFiles.files.append((location, fileInfos))
            }
            return docFiles
        } catch {
            print(error)
            fatalError("lets berak stuff")
        }
    }
}
