//
//  ImageProtoImp.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/10/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//


import Foundation

class VideoEncryption {
    required init()  {}
    static let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    
    static func saveVideoFileInDocuemnts(data:Data) throws -> String{
        let dateURL = Date().saveVideoDate() + ".mov"
        let completeURL = URL(fileURLWithPath: VideoEncryption.documentDirectoryPath.appendingPathComponent(dateURL))
        
        do{
            try data.write(to: completeURL)
            return dateURL
        }catch let error{
            print(error.localizedDescription)
            throw error
        }
    }
    
    static func saveVideoFileInDocuemnts(data:Data, withFileDate: String) throws -> String {
        let completeURL = URL(fileURLWithPath: Constants.documentDirectoryPath.appendingPathComponent(withFileDate))
        do{
            try data.write(to: completeURL)
            return completeURL.path
        }catch let error{
            print(error.localizedDescription)
            throw error
        }
    }
    
    static func getCompleteDocumentsURL(fileName:String)->URL{
        let completeURL = URL(fileURLWithPath: Constants.documentDirectoryPath.appendingPathComponent(fileName))
        return completeURL
    }
}
