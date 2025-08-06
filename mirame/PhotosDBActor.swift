//
//  PhotosDBActor.swift
//  mirame
//
//  Created by Trey Tartt on 5/1/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import SwiftData
import Foundation

@ModelActor
actor PhotosDBActor {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Photo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema,
                                                    isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    static let shared = PhotosDBActor(modelContainer: sharedModelContainer)
    
    public func deletePhoto(photo: Photo) {
        photo.imageData = nil
        photo.videoFileName = nil
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }
    
    public func getAll<T: PersistentModel>() throws -> [T] {
        do {
            let fetchDescriptor = FetchDescriptor<T>()
            let data = try modelContext.fetch(fetchDescriptor)
            return data
        } catch {
            return []
        }
    }
    
    public func randomPhoto(withPredicate predicate: Predicate<Photo>) throws -> Photo? {
        let allPhotos: [Photo] = try getAll().filter(predicate)
        guard !allPhotos.isEmpty else {
            return nil
        }
        let randomIndex = Int.random(in: 0..<allPhotos.count)
        return allPhotos[randomIndex]
    }
}
extension PhotosDBActor {
    @discardableResult
    func savePhotoToDB(photo: Photo, writeToDB: Bool = true) -> String? {
        modelContext.insert(photo)
        
        if !writeToDB { return "-1" }
        
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
        
        NotificationCenter.default.post(name: Notification.Name("AddedNewPhoto"),
                                        object: nil,
                                        userInfo: ["photo": photo])
        return photo.photoID.uuidString
    }
    
    func deleteLocally(photo: Photo) {
        photo.imageData = nil
        photo.videoFileName = nil
        do {
            try modelContext.save()
            NotificationCenter.default.post(name: Notification.Name("DeletedPhoto"),
                                            object: nil,
                                            userInfo: ["photo": photo])
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
            try modelContext.save()
        } catch {
            print(error)
        }
    }
    
    func favorite(photo: Photo, isFavorite: Bool) throws -> Bool {
        photo.isFavorite = isFavorite
        
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
        return photo.isFavorite!
    }
    
    func update(photo: Photo, imageData: Data) throws {
        photo.imageData = imageData
        
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }
    
    func photoWithImportedID(id: UUID) -> Photo? {
        do {
            let photoById = FetchDescriptor<Photo>(predicate: #Predicate { photo in
                photo.id == id
            })
            
            if let photo = try modelContext.fetch(photoById).first {
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
                deleteLocally(photo: photo)
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
    
    func deleteAll() {
        do {
            try modelContext.delete(model: Photo.self)
        } catch {
            print("Failed to delete students.")
        }
    }
}
