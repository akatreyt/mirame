//
//  DBProtoImp.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/1/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import Foundation
import RealmSwift
import SneakySync
import KeychainSwift
import UIKit

class PhotoDataStore: ObservableObject {
    static public let shared = PhotoDataStore()
    private var token: NotificationToken? = nil
    private var currentFilterString = DataBase.haveDataFilter
    private var currentSortDescriptor: RealmSwift.SortDescriptor?
    
    private init() {
        token = photos.observe { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial(_):
                break
            case .update(_, _, let insertions, let modifications):
//                for index in insertions {
//                    print(index)
//                }
//                for index in modifications {
//                    let all = DataBase.realm.objects(Photo.self)
//                    let photo = all[index]
//                    if photo.videoURL == nil && photo.iamgeData == nil {
//                        if let existingObjIdx = photos.firstIndex(where: {
//                            $0.id == photo.id
//                        }) {
//                            print(existingObjIdx)
//                        }
//                    }
//                    print(photo)
//                }
                updateResults()
            case .error(_):
                break
            }
        }
    }
    
    deinit {
        token?.invalidate()
    }
    
//    @ObservedResults(Photo.self, filter: NSPredicate(format: DataBase.haveDataFilter)) public var photos
    @Published var photos: Results<Photo> = DataBase.realm.objects(Photo.self).filter(DataBase.haveDataFilter)
        
    func deleteAll() {
        updateResults()
    }
    
    func setSortDesctriptors(_ sortDesctriptors: RealmSwift.SortDescriptor) {
        currentSortDescriptor = sortDesctriptors
        updateResults()
    }
    
    func setFilter(filter: String) {
        currentFilterString = filter
        updateResults()
    }
    
    private func updateResults() {
        photos = DataBase.realm.objects(Photo.self).filter(currentFilterString)
    }
}

class DataBase {
    static var encryptKeyKey = "realmEncryptKey"
    static let haveDataFilter: String = "(iamgeData != nil || videoURL != nil)"

    static let shared = DataBase()
    
    private init() {}
    
    private static var realmInstance: Realm?
    
    static var realm: Realm {
        if let realmInstance {
            return realmInstance
        }
        guard let db = DataBase.dbStuff() else {
            fatalError()
        }
        realmInstance = db
        return db
    }
    
    static func dbStuff() -> Realm? {
        // delete key for testing
        // try! KeychainImp.deleteValue(for: DB.encryptKeyKey)
        do {
            DataBase.validateDBKeyExists()
            let encryptKey = KeychainSwift().getData(DataBase.encryptKeyKey)
            
            var config = Realm.Configuration(
                // Set the new schema version. This must be greater than the previously used
                // version (if you've never set a schema version before, the version is 0).
                schemaVersion: 4,
                
                // Set the block which will be called automatically when opening a Realm with
                // a schema version lower than the one set above
                migrationBlock: { migration, oldSchemaVersion in
                    // We haven’t migrated anything yet, so oldSchemaVersion == 0
                    if (oldSchemaVersion < 2)  {
                        migration.enumerateObjects(ofType: Photo.className()) { oldObject, newObject in
                            newObject?["isFavorite"] = false
                        }
                    }
                    
                    if (oldSchemaVersion < 3)  {
                        migration.enumerateObjects(ofType: Photo.className()) { oldObject, newObject in
                            newObject?["importedID"] = "-1"
                        }
                    }
                    
                    if (oldSchemaVersion < 4)  {
                        migration.enumerateObjects(ofType: Photo.className()) { oldObject, newObject in
                            newObject?["disableFeedPreview"] = false
                        }
                    }
                })
            config.encryptionKey = encryptKey
            Realm.Configuration.defaultConfiguration = config
            return try Realm(configuration: config)
        } catch {
            return nil
        }
    }
    
    static func validateDBKeyExists() {
        guard let _ = KeychainSwift().getData(DataBase.encryptKeyKey) else {
            do {
                var key = Data(count: 64)
                _ = key.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) in
                    SecRandomCopyBytes(kSecRandomDefault, 64, pointer.baseAddress!) }
                KeychainSwift().set(key, forKey: DataBase.encryptKeyKey)
            } catch {
                fatalError()
            }
            return
        }
    }
    
    static func canOpenRealm() -> Bool {
        if let _ = dbStuff() {
            return true
        }
        return false
    }
}

/* search */
extension DataBase {
    static func photoWithID(id: String) -> Photo? {
        let photo = realm.objects(Photo.self).filter({ $0.id == id}).first
        return photo
    }

    static func photoWithImportedID(id: String) -> Photo? {
        let photo = realm.objects(Photo.self).filter({ $0.importedID == id}).first
        return photo
    }
}

/* save and delete */
extension DataBase {
    @MainActor @discardableResult
    static func saveLocally(photo: Photo) throws -> String? {
        do{
            let realm = DataBase.realm
            try realm.write {
                realm.add(photo, update: .all)
//                PhotoDataStore.shared.addObject(photo)
            }
            return photo.id
        }catch{
            throw error
        }
    }
    
    static func deleteAllForKey(key: KeyDataSet) throws {
        fatalError("fix this")
//        do{
//            let photos = DataBase.getAllPhotosResults(withFilter: "localImage == 0").filter({ $0.privateKeyUUID == key.id })
//            for photo in photos {
//                try deleteLocally(photo: photo)
//            }
//        }catch{
//            throw error
//        }
    }
    
    static func deleteLocally(photo: Photo) throws {
        do{
            if photo.isVideo == 1 {
                let url = VideoEncryption.getCompleteDocumentsURL(fileName: photo.videoURL!)
                try FileManager.default.removeItem(at: URL(fileURLWithPath: url.path))
            }
            
            let realm = DataBase.realm
            try realm.write {
                // never delete a photo, keep it around so if a user tries to import the same
                // photo again we have the id to check against
                photo.iamgeData = nil
                photo.videoURL = nil
                //                    PhotoDataStore.shared.deleteObject(photo)
            }
        } catch {
            print(error)
        }
    }
    
    static func deleteAll() {
        do{
            let realm = DataBase.realm
            try realm.write {
                realm.deleteAll()
                PhotoDataStore.shared.deleteAll()
            }
        } catch {
            print(error)
        }
    }
    
    static func deleteViewedPhotosIfNeeded() -> Bool {
        var deletedOne = false
        let filter = "localImage == 0 && " + haveDataFilter
        DataBase.realm.objects(Photo.self).filter(filter).filter({
            $0.localImage == 0 &&
            $0.numberOfViews >= $0._allowedNumberOfViewsCount
        }).forEach({ photo in
            do {
                try DataBase.deleteLocally(photo: photo)
                deletedOne = true
            } catch {
                
            }
        })
        
//        DB.getAllPhotos().forEach({ photo in
//            do {
//                try! realm.write {
//                    photo.localImage = 0
//                }
//            } catch {
//                
//            }
//        })
        
        return deletedOne
    }
    
    static func saveVideo(_ url: URL) async throws {
        do{
            try await SaveDeleteContent.saveVideo(importedPhotoID: nil, keyDataSet: KeychainKeys.shared.personalKey, fileURL: url, isLocal: true, disableFeedPreview: false)
        }catch{
            throw error
        }
    }
}

extension DataBase {
    static func exportPersonalDBKey() -> String? {
        let fileName = Constants.randomTokenName + "." + Constants.mirameExtension
        guard let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName) else{
            return nil
        }
        do{
            if let dbData = KeychainSwift().getData(DataBase.encryptKeyKey) {
                if try FileWriter.write(data: dbData, toURL: url) {
                    return url.absoluteString
                }
            }
        }catch{
            print(error)
            return nil
        }
        return nil
    }
}
