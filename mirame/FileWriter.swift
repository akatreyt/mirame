//
//  FileWriter.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/10/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import Foundation

class FileWriter {
    static func write(data _data: Data, toURL url: URL) throws -> Bool {
        do{
            try _data.write(to: url)
            return true
        }catch{
            throw error
        }
    }
}
