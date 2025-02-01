//
//  FileParser.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/28/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//
import Foundation

enum ParsingError : Error {
    case invalidData
    case invalidFormat
    case missingPrivateKey
    case keyIsMissingName
}

protocol SneakerParser {
    static func parseAndSave(data : Data) async -> AlertConfig?
}

class FileParser {
    static let parsers = [PhotoParser.self] as [SneakerParser.Type]
    
    @MainActor
    static func doWork(url : URL, hasTriedUnlocked: Bool = false) async throws -> AlertConfig {
        do {
            if url.absoluteString.contains(Constants.mirameExtension) {
                let data = try Data(contentsOf: url)
                
                for parser in parsers {
                    if let alertConfig = await parser.parseAndSave(data: data) {
                        return alertConfig
                    }
                }
            }
        } catch {
            if url.startAccessingSecurityScopedResource() {
                if url.absoluteString.contains(Constants.mirameExtension) {
                    let data = try Data(contentsOf: url)
                    
                    for parser in parsers {
                        if let alertConfig = await parser.parseAndSave(data: data) {
                            return alertConfig
                        }
                    }
                }
            }
            
            return AlertConfig(
                title: "Error",
                message: "there was an error",
                buttons: [AlertConfigButton.generalError]
            )
        }
        return AlertConfig(
            title: "Error",
            message: "there was an error",
            buttons: [AlertConfigButton.generalError]
        )
    }
}

//class DBParser: SneakerParser {
//    static func parseAndSave(data : Data) -> AlertConfig? {
//        do{
//            try KeychainImp.testSaveDBKey(value: data, key: DataBase.encryptKeyKey)
//            return AlertConfig(
//                title: "Success",
//                message: "Saved db key",
//                buttons: [AlertConfigButton.buttonOK]
//            )
//        }catch{
//            return nil
//        }
//    }
//}

//class PersonalKeyParser: SneakerParser {
//    static func parseAndSave(data : Data) -> AlertConfig? {
//        do{
//            let pKey = try JSONDecoder().decode(PrivateKey.self, from: data)
//            try KeychainKeys.shared.saveLocally(key: pKey, importing: false)
//            return AlertConfig(
//                title: "Success",
//                message: "Saved key",
//                buttons: [AlertConfigButton.buttonOK]
//            )
//        }catch{
//            return nil
//        }
//    }
//}

//class PrivateKeyParser: SneakerParser {
//    static func parseAndSave(data : Data) -> AlertConfig? {
//        do{
//            var key = try PrivateKey.decode(fromData: data)
//            if key.name == nil {
//                throw ParsingError.keyIsMissingName
//            }
//            key.imported = true
//            try KeychainKeys.shared.saveLocally(key: key, importing: true)
//            return AlertConfig(
//                title: "Success",
//                message: "Saved key",
//                buttons: [AlertConfigButton.buttonOK]
//            )
//        }catch{
//            return nil
//        }
//    }
//}

class PhotoParser: SneakerParser {
    @MainActor
    static func parseAndSave(data : Data) async -> AlertConfig? {
        for key in KeychainKeys.shared.allKeys {
            do {
                let results = try await ImportExport.decodeAndSave(data: data, keyDataSet: key)
                
                // if there is only one error, and the error int is 2 its a decoding error, move on to the next key
                if results.count == 1 && results.first?.1 == 2 {
                    continue
                }
                var errorString = ""
                
                for result in results {
                    if let error = result.2 {
                        errorString += error + "\n"
                    }
                }
                
                let title = errorString.isEmpty ? "Success" : "Success ... kinda"
                let message = errorString.isEmpty ? "Saved new Photo" : errorString
                
                return AlertConfig(
                    title: title,
                    message: message,
                    buttons: [AlertConfigButton.buttonOK]
                )
            } catch {
                return nil
            }
        }
        return nil
    }
}
