//
//  DBProtoImp.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/1/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import Foundation
import SneakySync
import KeychainSwift
import UIKit
import SwiftData

@MainActor
class DataBase {
    static let shared = DataBase()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Photo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
        
    func deleteAll() {
        do {
            try sharedModelContainer.mainContext.delete(model: Photo.self)
        } catch {
            print("Failed to delete students.")
        }
    }
    
    @discardableResult
    func savePhotoToDB(photo: Photo) -> String? {
        sharedModelContainer.mainContext.insert(photo)
        return photo.id?.uuidString
    }
    
    func deleteLocally(photo: Photo) {
        photo.imageData = nil
        photo.videoFileName = nil
        do {
            try sharedModelContainer.mainContext.save()
        } catch {
            print(error)
        }
    }
    
    func incrementViewCount(photo: Photo) {
        if var numberOfViews = photo.numberOfViews {
            numberOfViews += 1
            photo.numberOfViews = numberOfViews
        } else {
            photo.numberOfViews = 1
        }
        
        photo.lastViewDate = Date()
        
        do {
            try sharedModelContainer.mainContext.save()
        } catch {
            print(error)
        }
    }
    
    func favorite(photo: Photo, isFavorite: Bool) throws -> Bool {
        photo.isFavorite = isFavorite
        
        do {
            try sharedModelContainer.mainContext.save()
        } catch {
            print(error)
        }
        return photo.isFavorite!
    }
    
    func update(photo: Photo, imageData: Data) throws {
        photo.imageData = imageData
        
        do {
            try sharedModelContainer.mainContext.save()
        } catch {
            print(error)
        }
    }
    
    func photoWithImportedID(id: UUID) -> Photo? {
        return nil
    }
    
    func deleteViewedPhotosIfNeeded() -> Bool {
//        var deletedOne = false
//        let filter = "localImage == 0 && " + haveDataFilter
//        DataBase.realm.objects(Photo.self).filter(filter).filter({
//            $0.localImage == 0 &&
//            $0.numberOfViews >= $0._allowedNumberOfViewsCount
//        }).forEach({ photo in
//            do {
//                try DataBase.deleteLocally(photo: photo)
//                deletedOne = true
//            } catch {
//                
//            }
//        })
        
        //        DB.getAllPhotos().forEach({ photo in
        //            do {
        //                try! realm.write {
        //                    photo.localImage = 0
        //                }
        //            } catch {
        //
        //            }
        //        })
        
        return false
    }
}
