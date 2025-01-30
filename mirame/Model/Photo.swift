//
//  Photo.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/6/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import Foundation
import SwiftUI
import SneakySync
import SwiftData

enum PhotoErrors : Error{
    case ErrorCompletingSelf
    case maxNumberOfViewsReached
}

struct PhotoShareObject: Codable, Identifiable {
    var imageData : Data?
    var savedDate : Date?
    var takenBy : String?
    var takenDate : Date?
    var id: UUID
    var isVideo: Bool
    var videoFileName: String?
    var localImage: Bool
    var allowedNumberOfViews: Int
    var screenShotsAllowed: Bool
    var numberOfViews: Int
    var lastViewDate : Date?
    var privateKeyUUID : String?
    var keyName : String?
    var disableFeedPreview: Bool?
    
    init(id: UUID, imageData: Data?, savedDate: Date?, takenBy: String?, takenDate: Date?, isVideo: Bool, videoFileName: String?, localImage: Bool, allowedNumberOfViews: Int, screenShotsAllowed: Bool, numberOfViews: Int, lastViewDate: Date?, privateKeyUUID: String?, keyName: String? , disableFeedPreview: Bool?) {
        self.id = id
        self.imageData = imageData
        self.savedDate = savedDate
        self.takenBy = takenBy
        self.takenDate = takenDate
        self.id = id
        self.isVideo = isVideo
        self.videoFileName = videoFileName
        self.localImage = localImage
        self.allowedNumberOfViews = allowedNumberOfViews
        self.screenShotsAllowed = screenShotsAllowed
        self.numberOfViews = numberOfViews
        self.lastViewDate = lastViewDate
        self.privateKeyUUID = privateKeyUUID
        self.keyName = keyName
        self.disableFeedPreview = disableFeedPreview
    }
}

@Model
class Photo: Identifiable, Codable {
    var id: UUID?

    var imageData : Data?
    var savedDate : Date?
    var takenBy : String?
    var takenDate : Date?
    var isVideo: Bool?
    var videoFileName: String?
    var localImage: Bool?
    var allowedNumberOfViews: Int?
    var screenShotsAllowed: Bool?
    var numberOfViews: Int?
    var lastViewDate : Date?
    var privateKeyUUID : String?
    var keyName : String?
    var isFavorite: Bool? = false
    var importedID : UUID?
    var disableFeedPreview : Bool?
    
    var photoID : UUID {
        if let id = id {
            return id
        }
        id = UUID()
        return id!
    }
    
//    var _allowedNumberOfViewsCount : Int {
//        allowedNumberOfViews == -1 ? Int.max : allowedNumberOfViews
//    }
    
    init(id: UUID, imageData: Data?, savedDate: Date?, takenBy: String?, takenDate: Date, isVideo: Bool, videoFileName: String?, localImage: Bool, allowedNumberOfViews: Int, screenShotsAllowed: Bool, numberOfViews: Int, lastViewDate: Date?, privateKeyUUID: String?, keyName: String?, isFavorite: Bool, importedID: UUID?, disableFeedPreview: Bool) {
        self.id = id
        self.imageData = imageData
        self.savedDate = savedDate
        self.takenBy = takenBy
        self.takenDate = takenDate
        self.isVideo = isVideo
        self.videoFileName = videoFileName
        self.localImage = localImage // did the user take the photo
        self.allowedNumberOfViews = allowedNumberOfViews
        self.screenShotsAllowed = screenShotsAllowed
        self.numberOfViews = numberOfViews
        self.lastViewDate = lastViewDate
        self.privateKeyUUID = privateKeyUUID
        self.keyName = keyName
        self.isFavorite = isFavorite
        self.importedID = importedID
        self.disableFeedPreview = disableFeedPreview
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageData
        case savedDate
        case takenBy
        case takenDate
        case isVideo
        case videoFileName
        case localImage
        case allowedNumberOfViews
        case screenShotsAllowed
        case numberOfViews
        case lastViewDate
        case privateKeyUUID
        case keyName
        case isFavorite
        case importedID
        case disableFeedPreview
        case unlockedData
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        savedDate = try container.decodeIfPresent(Date.self, forKey: .savedDate)
        takenBy = try container.decodeIfPresent(String.self, forKey: .takenBy)
        takenDate = try container.decodeIfPresent(Date.self, forKey: .takenDate)
        isVideo = try container.decodeIfPresent(Bool.self, forKey: .isVideo)
        videoFileName = try container.decodeIfPresent(String.self, forKey: .videoFileName)
        localImage = try container.decodeIfPresent(Bool.self, forKey: .localImage)
        allowedNumberOfViews = try container.decodeIfPresent(Int.self, forKey: .allowedNumberOfViews)
        screenShotsAllowed = try container.decodeIfPresent(Bool.self, forKey: .screenShotsAllowed)
        numberOfViews = try container.decodeIfPresent(Int.self, forKey: .numberOfViews)
        lastViewDate = try container.decodeIfPresent(Date.self, forKey: .lastViewDate)
        privateKeyUUID = try container.decodeIfPresent(String.self, forKey: .privateKeyUUID)
        keyName = try container.decodeIfPresent(String.self, forKey: .keyName)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite)
        importedID = try container.decodeIfPresent(UUID.self, forKey: .importedID)
        disableFeedPreview = try container.decodeIfPresent(Bool.self, forKey: .disableFeedPreview)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(imageData, forKey: .imageData)
        try container.encode(savedDate, forKey: .savedDate)
        try container.encode(takenBy, forKey: .takenBy)
        try container.encode(isVideo, forKey: .isVideo)
        try container.encode(videoFileName, forKey: .videoFileName)
        try container.encode(localImage, forKey: .localImage)
        try container.encode(allowedNumberOfViews, forKey: .allowedNumberOfViews)
        try container.encode(screenShotsAllowed, forKey: .screenShotsAllowed)
        try container.encode(numberOfViews, forKey: .numberOfViews)
        try container.encode(imageData, forKey: .imageData)
        try container.encode(lastViewDate, forKey: .lastViewDate)
        try container.encode(privateKeyUUID, forKey: .privateKeyUUID)
        try container.encode(keyName, forKey: .keyName)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(importedID, forKey: .importedID)
        try container.encode(disableFeedPreview, forKey: .disableFeedPreview)
        try container.encode(savedDate, forKey: .savedDate)
    }
}

extension Photo {
    var shareObject : PhotoShareObject {
        return PhotoShareObject(
            id: self.photoID,
            imageData: self.imageData,
            savedDate: self.savedDate,
            takenBy: self.takenBy,
            takenDate: self.takenDate,
            isVideo: self.isVideo ?? false,
            videoFileName: videoFileName,
            localImage: self.localImage ?? false,
            allowedNumberOfViews: self.allowedNumberOfViews ?? -1,
            screenShotsAllowed: self.screenShotsAllowed ?? false,
            numberOfViews: self.numberOfViews ?? 0,
            lastViewDate: lastViewDate,
            privateKeyUUID: self.privateKeyUUID,
            keyName: self.keyName,
            disableFeedPreview: self.disableFeedPreview)
    }
}

extension Photo{
    func videoData() throws -> Data {
        let url = VideoEncryption.getCompleteDocumentsURL(fileName: self.videoFileName!)
        do{
            let _data = try Data(contentsOf: URL(fileURLWithPath: url.path))
            return _data
        }catch{
            throw error
        }
    }
}

extension Photo{
    static func toData(photo : Photo) throws -> Data{
        do{
            // since were sharing a photo that is locally stored we have to decrypt the
            // image with the local users personal key
            let tmpPhoto = photo
            if let isVideo = tmpPhoto.isVideo, isVideo {
                if let _videoURL = tmpPhoto.videoFileName {
                    let url = VideoEncryption.getCompleteDocumentsURL(fileName: _videoURL)
                    let enctrypedData = try Data(contentsOf: url)
                    let _decryptedData = try PrivateKeyStuff.decryptUsing(data: enctrypedData, keyDataSet: KeychainKeys.shared.personalKey)
                    tmpPhoto.imageData = Data(base64Encoded: _decryptedData)!
                }
            } else {
                if let enctrypedData = tmpPhoto.imageData {
                    let _decryptedData = try PrivateKeyStuff.decryptUsing(data: enctrypedData, keyDataSet: KeychainKeys.shared.personalKey)
                    tmpPhoto.imageData = Data(base64Encoded: _decryptedData)!
                }
            }
            let jsonData = try JSONEncoder().encode(tmpPhoto)
            return jsonData
        }catch{
            throw(error)
        }
    }
    
    static func from(data : Data) throws -> Photo {
        do{
            let decoded = try JSONDecoder().decode(Photo.self, from: data)
            return decoded
        }catch{
            throw(error)
        }
    }
    
    func decrypt(withKey keyDataSet: KeyDataSet) -> Data? {
        guard let _data = self.imageData else {
            return nil
        }
        
        if let _decryptedData = try? PrivateKeyStuff.decryptUsing(data: _data, keyDataSet: keyDataSet) {
            return Data(base64Encoded: _decryptedData)!
        }
        return nil
    }
}

extension Photo {
    func showImage(key: KeyDataSet) -> UIImage? {
        if let _data = self.imageData {
            if let decryptedData = try? PrivateKeyStuff.decryptUsing(data: _data, keyDataSet: key),
               let _image = UIImage(data: decryptedData)  {
                return _image
            }
            return nil
        }
        return nil
    }
    
    func showVideo(key: KeyDataSet) -> URL? {
        do {
            if let _videoURL = self.videoFileName {
                let url = VideoEncryption.getCompleteDocumentsURL(fileName: _videoURL)
                if FileManager.default.fileExists(atPath: url.path){
                    var playURL = url
                    
                    let enctrypedData = try Data(contentsOf: url)
                    let decryptedData = try PrivateKeyStuff.decryptUsing(data: enctrypedData, keyDataSet: key)
                    let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
                    let targetURL = tempDirectoryURL.appendingPathComponent(_videoURL)
                    try decryptedData.write(to: targetURL)
                    playURL = targetURL
                    return playURL
                }
            }
        } catch {
            return nil
        }
        return nil
    }
}
