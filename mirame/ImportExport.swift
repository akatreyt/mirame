//
//  SharedFile.swift
//  mirame-ios
//
//  Created by Trey Tartt on 11/2/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import Foundation
import UIKit
import SneakySync

class ImportExport {
    static func encode(photos phs: [PhotoShareObject], keyDataSet: KeyDataSet) throws -> URL {
        do{
            let tmpFileURL = try URL.createSneakyFileLocation()
            var allPhotos = [Data]()
            phs.forEach({
                if let data = try? JSONEncoder().encode($0) {
                    allPhotos.append(data)
                }
            })
            let allPhotosData = try JSONEncoder().encode(allPhotos)
            let enctrypedData = try PrivateKeyStuff.encryptUsing(data: allPhotosData, keyDataSet: keyDataSet)
            try FileWriter.write(data: enctrypedData, toURL: tmpFileURL)
            
            return tmpFileURL
        }catch{
            throw(error)
        }
    }
    
    @MainActor
    static func decodeAndSave(data: Data, keyDataSet: KeyDataSet) async throws -> [(Bool, Int, String?)] {
        var allResults: [(Bool, Int, String?)] = []
        do{
            let decryptedData = try PrivateKeyStuff.decryptUsing(data: data, keyDataSet: keyDataSet)
            let decodedArray = try JSONDecoder().decode([Data].self, from: decryptedData)
            
            for item in decodedArray {
                let photoToShow = try JSONDecoder().decode(PhotoShareObject.self, from: item)
                
                // if this photo already exist update the image data but keep all other data
                if let photo = DataBase.photoWithImportedID(id: photoToShow.id),
                   let imageData = photoToShow.iamgeData {
                    try photo.update(imagedata: imageData)
                    allResults.append((true, 0, nil))
                } else {
                    if let imageData = photoToShow.iamgeData {
                        if photoToShow.isVideo == 1 {
                            if let videoURL = photoToShow.videoURL {
                                // get image from imported file, its decoded at this stage
                                // save image to docs so we can use the same saveVideo function as taking a video
                                // but it saves
                                let _videoURL = try VideoEncryption.saveVideoFileInDocuemnts(data: imageData, withFileDate: videoURL)
                                
                                // save unencrypted Photo in db with key
                                let _ =  try await SaveDeleteContent.saveVideo(importedPhotoID: photoToShow.id,
                                                                               keyDataSet: keyDataSet,
                                                                               fileURL: URL(fileURLWithPath: _videoURL),
                                                                               isLocal: false,
                                                                               disableFeedPreview: photoToShow.disableFeedPreview ?? false)
                                allResults.append((true, 0, nil))
                            } else {
                                allResults.append((false, 1, "Error importing video"))
                            }
                        } else {
                            if let image = UIImage(data: imageData){
                                var takenDate = Date()
                                if let _takenDate = photoToShow.takenDate{
                                    takenDate = _takenDate
                                }
                                let _ =  try await SaveDeleteContent.savePhoto(importedPhotoID: photoToShow.id,
                                                                               image: image,
                                                                               keyDataSet: keyDataSet,
                                                                               isLocal: false,
                                                                               allowedNumOfViews: photoToShow.allowedNumberOfViews,
                                                                               allowScreenShots: photoToShow.screenShotsAllowed == 1 ? true : false,
                                                                               takenDate:takenDate,
                                                                               disableFeedPreview: photoToShow.disableFeedPreview ?? false)
                                allResults.append((true, 0, nil))
                            } else {
                                allResults.append((false, 1, "Error importing photo"))
                            }
                        }
                    }
                }
            }
        } catch {
            allResults.append((false, 2, "Error importing media"))
        }
        return allResults
    }
}
