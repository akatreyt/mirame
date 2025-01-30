//
//  SaveUpload.swift
//  mirame-ios
//
//  Created by Trey Tartt on 2/9/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import Realm
import RealmSwift
import SneakySync

/*
 if were sending it to somebody we're sending it with their public key
 encrypt using their public key
 
 if were getting sent something its signed with our public key
 decrypt using our private key
 */


class SaveDeleteContent {
    required init(){}
    
    @discardableResult
    static func savePhoto(importedPhotoID: String?, image: UIImage, keyDataSet: KeyDataSet, isLocal: Bool, allowedNumOfViews: Int = -1, allowScreenShots : Bool = false, takenDate : Date = Date(), disableFeedPreview : Bool) async throws -> String {
        
        let newImage = image.fixOrientation()
        let newPhoto = Photo()
        if let _data = newImage.pngData() {
            let enctrypedData = try PrivateKeyStuff.encryptUsing(data: _data, keyDataSet: keyDataSet)
            newPhoto.iamgeData = enctrypedData
            newPhoto.savedDate = Date()
            newPhoto.privateKeyUUID = keyDataSet.id.uuidString
            newPhoto.localImage = isLocal ? 1 : 0
            newPhoto.allowedNumberOfViews = allowedNumOfViews
            newPhoto.screenShotsAllowed = allowScreenShots ? 1 : 0
            newPhoto.takenDate = takenDate
            newPhoto.importedID = importedPhotoID
            newPhoto.disableFeedPreview = disableFeedPreview
            
            do{
                if let id = try await DataBase.saveLocally(photo: newPhoto) {
                    return id
                } else {
                    throw UIAlertTypes.errorSaving
                }
            }catch{
                throw error
            }
        }else{
            throw UIAlertTypes.errorSaving
        }
    }
    
    @discardableResult
    static func saveVideo(importedPhotoID: String?, keyDataSet: KeyDataSet, fileURL: URL, isLocal: Bool, disableFeedPreview : Bool) async throws -> Photo {
        do{
            // unencrypted video data
            let data = try Data(contentsOf: fileURL)
            
            // delete unencrypted video from file system
            try FileManager.default.removeItem(at: fileURL)
            
            let encryptedData = try PrivateKeyStuff.encryptUsing(data: data, keyDataSet: keyDataSet)
            let fileName = try VideoEncryption.saveVideoFileInDocuemnts(data: encryptedData)
            let newPhoto = Photo()
            newPhoto.videoURL = fileName
            newPhoto.savedDate = Date()
            newPhoto.isVideo = 1
            newPhoto.privateKeyUUID = keyDataSet.id.uuidString
            newPhoto.localImage = isLocal ? 1 : 0
            newPhoto.takenDate = Date()
            newPhoto.importedID = importedPhotoID
            newPhoto.disableFeedPreview = disableFeedPreview
            
            try await DataBase.saveLocally(photo: newPhoto)
            return newPhoto
        }catch{
            throw error
        }
    }
    
    func delete(photo:Photo)throws {
        do{
            try DataBase.deleteLocally(photo: photo)
        }catch{
            throw error
        }
    }
    
//    static func deleteOldVideoFiles() {
//        var videoFiles = [String]()
//        DataBase.getAllPhotosResults(withFilter: "localImage == 0").forEach({ photo in
//            if photo.isVideo == 1{
//                videoFiles.append(photo.videoURL!)
//            }
//        })
//        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        do {
//            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
//            print(directoryContents)
//            
//            let movFiles = directoryContents.filter{ $0.pathExtension == "mov" }
//            let movFileNames = movFiles.map{ $0.deletingPathExtension().lastPathComponent }
//            for movFile in movFileNames{
//                let _movFile = movFile+".mov"
//                if !videoFiles.contains(_movFile){
//                    let url = getCompleteDocumentsURL(fileName: _movFile)
//                    try FileManager.default.removeItem(at: URL(fileURLWithPath: url.path))
//                }
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    
    static func getCompleteDocumentsURL(fileName:String)->URL{
        let completeURL = URL(fileURLWithPath: Constants.documentDirectoryPath.appendingPathComponent(fileName))
        return completeURL
    }
}
