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
    static func savePhoto(importedPhotoID: UUID?, image: UIImage, keyDataSet: KeyDataSet, isLocal: Bool, allowedNumOfViews: Int = -1, allowScreenShots : Bool = true, takenDate : Date = Date(), disableFeedPreview : Bool) async throws -> String {
        
        let newImage = image.fixOrientation()
        
        if let _data = newImage.pngData() {
            let enctrypedData = try PrivateKeyStuff.encryptUsing(data: _data, keyDataSet: keyDataSet)
            
            let newPhoto = Photo(
                id: UUID(),
                imageData: enctrypedData,
                savedDate: Date(),
                takenBy: nil,
                takenDate: takenDate,
                isVideo: false,
                videoFileName: nil,
                localImage: isLocal,
                allowedNumberOfViews: allowedNumOfViews,
                screenShotsAllowed: allowScreenShots,
                numberOfViews: 0,
                lastViewDate: nil,
                privateKeyUUID: keyDataSet.id.uuidString,
                keyName: keyDataSet.name,
                isFavorite: false,
                importedID: importedPhotoID,
                disableFeedPreview: disableFeedPreview
            )
            
            do{
                if let id = try await DataBase.shared.saveLocally(photo: newPhoto) {
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
    static func saveVideo(importedPhotoID: UUID, keyDataSet: KeyDataSet, fileURL: URL, isLocal: Bool, disableFeedPreview : Bool) async throws -> Photo {
        do{
            // unencrypted video data
            let data = try Data(contentsOf: fileURL)
            
            // delete unencrypted video from file system
            try FileManager.default.removeItem(at: fileURL)
            
            let encryptedData = try PrivateKeyStuff.encryptUsing(data: data, keyDataSet: keyDataSet)
            let fileName = try VideoEncryption.saveVideoFileInDocuemnts(data: encryptedData)
            let newPhoto = Photo(
                id: UUID(),
                imageData: nil,
                savedDate: Date(),
                takenBy: nil,
                takenDate:  Date(),
                isVideo: true,
                videoFileName: fileName,
                localImage: isLocal,
                allowedNumberOfViews: -1,
                screenShotsAllowed: true,
                numberOfViews: 0,
                lastViewDate: nil,
                privateKeyUUID: keyDataSet.id.uuidString,
                keyName: keyDataSet.name,
                isFavorite: false,
                importedID: importedPhotoID,
                disableFeedPreview: disableFeedPreview
            )
            
            try await DataBase.shared.saveLocally(photo: newPhoto)
            return newPhoto
        }catch{
            throw error
        }
    }
    
    @MainActor
    func delete(photo:Photo)throws {
        do{
            try DataBase.shared.deleteLocally(photo: photo)
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
