//
//  Photo.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/6/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftUI
import SneakySync

enum PhotoErrors : Error{
    case ErrorCompletingSelf
    case maxNumberOfViewsReached
}

class PhotoShareObject: Codable, Identifiable {
    var iamgeData : Data?
    var savedDate : Date?
    var takenBy : String?
    var takenDate : Date?
    var id: String = UUID().uuidString
    var isVideo: Int = 0
    var videoURL: String? // realm wants a string
    var localImage: Int = 0
    var allowedNumberOfViews: Int = -1
    var screenShotsAllowed: Int = 0
    var numberOfViews: Int = 0
    var lastViewDate : Date?
    var privateKeyUUID : String?
    var keyName : String?
    var disableFeedPreview: Bool? = false
}

class Photo : Object, Codable, Identifiable, ObjectKeyIdentifiable {
    @Persisted dynamic var iamgeData : Data?
    @Persisted dynamic var savedDate : Date?
    @Persisted dynamic var takenBy : String?
    @Persisted dynamic var takenDate : Date?
    @Persisted dynamic var id: String = UUID().uuidString
    @Persisted dynamic var isVideo: Int = 0
    @Persisted dynamic var videoURL: String? // realm wants a string
    @Persisted dynamic var localImage: Int = 0
    @Persisted dynamic var allowedNumberOfViews: Int = -1
    @Persisted dynamic var screenShotsAllowed: Int = 0
    @Persisted dynamic var numberOfViews: Int = 0
    @Persisted dynamic var lastViewDate : Date?
    @Persisted dynamic var privateKeyUUID : String?
    @Persisted dynamic var keyName : String?
    @Persisted dynamic var isFavorite: Bool? = false
    @Persisted dynamic var importedID : String?
    @Persisted dynamic var disableFeedPreview : Bool? = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var _allowedNumberOfViewsCount : Int {
        allowedNumberOfViews == -1 ? Int.max : allowedNumberOfViews
    }
    
    @objc dynamic var unlockedData : Data?
    override static func ignoredProperties() -> [String] {
        return ["unlockedData"]
    }
    
    override init() {
        super.init()
    }
}

extension Photo {
    var shareObject : PhotoShareObject {
        let shareObject = PhotoShareObject()
        shareObject.iamgeData = self.iamgeData
        shareObject.savedDate = self.savedDate
        shareObject.takenBy = self.takenBy
        shareObject.takenDate = self.takenDate
        shareObject.id = self.id
        shareObject.isVideo = self.isVideo
        shareObject.videoURL = self.videoURL
        shareObject.localImage = self.localImage
        shareObject.allowedNumberOfViews = self.allowedNumberOfViews
        shareObject.screenShotsAllowed = self.screenShotsAllowed
        shareObject.numberOfViews = self.numberOfViews
        shareObject.lastViewDate = self.lastViewDate
        shareObject.privateKeyUUID = self.privateKeyUUID
        shareObject.keyName = self.keyName
        return shareObject
    }
}

extension Photo{
    func videoData() throws -> Data {
        let url = VideoEncryption.getCompleteDocumentsURL(fileName: self.videoURL!)
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
            let tmpPhoto = Photo(value: photo)
            if tmpPhoto.isVideo == 1 {
                if let _videoURL = tmpPhoto.videoURL{
                    let url = VideoEncryption.getCompleteDocumentsURL(fileName: _videoURL)
                    let enctrypedData = try Data(contentsOf: url)
                    let _decryptedData = try PrivateKeyStuff.decryptUsing(data: enctrypedData, keyDataSet: KeychainKeys.shared.personalKey)
                    tmpPhoto.iamgeData = Data(base64Encoded: _decryptedData)!
                }
            } else {
                if let enctrypedData = tmpPhoto.iamgeData {
                    let _decryptedData = try PrivateKeyStuff.decryptUsing(data: enctrypedData, keyDataSet: KeychainKeys.shared.personalKey)
                    tmpPhoto.iamgeData = Data(base64Encoded: _decryptedData)!
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
        guard let _data = self.iamgeData else {
            return nil
        }
        
        if let _decryptedData = try? PrivateKeyStuff.decryptUsing(data: _data, keyDataSet: keyDataSet) {
            return Data(base64Encoded: _decryptedData)!
        }
        return nil
    }
}

extension Photo {
    func incrementViewCount() throws {
        do {
            let realm = DataBase.realm
            try realm.write {
                self.numberOfViews += 1
                self.lastViewDate = Date()
            }
        } catch {
            throw error
        }
    }
    
    func favorite(isFavorite: Bool) throws -> Bool {
        do {
            let realm = DataBase.realm
            try realm.write {
                self.isFavorite = isFavorite
            }
        } catch {
            throw error
        }
        return isFavorite
    }
    
    func update(imagedata: Data) throws {
        do {
            let realm = DataBase.realm
            try realm.write {
                self.iamgeData = imagedata
            }
        } catch {
            throw error
        }
    }
}

extension Photo {
    func showImage(key: KeyDataSet) -> UIImage? {
        if let _data = self.iamgeData {
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
            if let _videoURL = self.videoURL{
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
