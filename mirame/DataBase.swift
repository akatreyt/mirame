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
        do {
            try sharedModelContainer.mainContext.save()
        } catch {
            print(error)
        }
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
        do {
            let photoById = FetchDescriptor<Photo>(predicate: #Predicate { photo in
                photo.id == id
            })
            
            if let photo = try sharedModelContainer.mainContext.fetch(photoById).first {
                return photo
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func deleteViewedPhotosIfNeeded(photos: [Photo]) -> Bool {
        var deletedOne = false
        
        let activePhotos = photos.filter({ photo in
            (photo.imageData != nil || photo.videoFileName != nil)
        })
        
        for photo in activePhotos {
            if let isLocal = photo.localImage,
               !isLocal,
               let maxNumberOfViews = photo.allowedNumberOfViews,
               maxNumberOfViews != -1,
               let numberOfViews = photo.numberOfViews,
                numberOfViews >= maxNumberOfViews {
                DataBase.shared.deleteLocally(photo: photo)
                deletedOne = true
            }
        }
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
}
