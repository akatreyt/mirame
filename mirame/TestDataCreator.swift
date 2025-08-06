//
//  TestDataCreator.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/11/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import Foundation
import UIKit
import SneakySync

class TestDataCreator {
    var fakeImportKeyDataSet: KeyDataSet
    
    init() {
        let salt = PrivateKeyStuff.generateSalt()
        let fakePersonal = PrivateKeyStuff.generateKeyPair(usingSalt: salt)
        let fakeImported = PrivateKeyStuff.generateKeyPair(usingSalt: salt)
        // since their sending it to us they would have their private key and our public key
        // we decrypt this using our private key
        var fakeKeyDataSet = KeyDataSet(privateKeyData: fakeImported.privateKey.rawRepresentation, publicKeyData: fakePersonal.publicKey?.rawRepresentation, salt: salt, id: UUID(), isActive: true)
        fakeKeyDataSet.name = "testImportData"
        
        self.fakeImportKeyDataSet = fakeKeyDataSet
    }
    
    @MainActor
    func populateTestData(completion: @escaping (() -> Void)) async {
        await PhotosDBActor.shared.deleteAll()
        KeychainKeys.shared.deleteAll()
        
        try! KeychainKeys.shared.saveLocally(key: fakeImportKeyDataSet)
        
        let queue = DispatchQueue(label: "thread-safe-array")
        
        do {
            let photos = try FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath).filter({ $0.hasSuffix("jpg") })
            let videos = try FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath).filter({ $0.hasSuffix("mp4") })
            var newPhotos = [Photo]()
            
            Task {
                await withTaskGroup(of: Void.self) { group in
                    for i in 0 ..< 400 {
                        group.addTask {
                            let photo = photos.randomElement()
                            let url = Bundle.main.url(forResource: photo, withExtension: "")!
                            let data = try! Data(contentsOf: url)
                            let image = UIImage(data: data)!
                            let newImage = image.fixOrientation()
                            
                            if let _data = newImage.pngData() {
                                let isLocal = Bool.random()
                                let keySet = isLocal ? KeychainKeys.shared.personalKey : self.fakeImportKeyDataSet
                                let enctrypedData = try! PrivateKeyStuff.encryptUsing(data: _data, keyDataSet: keySet)
                                
                                let newPhoto = Photo(
                                    id: UUID(),
                                    imageData: enctrypedData,
                                    savedDate: Calendar.current.date(byAdding: .day, value: -(Int.random(in: 0..<40)), to: Date())!,
                                    takenBy: nil,
                                    takenDate: Calendar.current.date(byAdding: .day, value: -(Int.random(in: 0..<40)), to: Date())!,
                                    isVideo: false,
                                    videoFileName: nil,
                                    localImage: isLocal,
                                    allowedNumberOfViews: -1,
                                    screenShotsAllowed: true,
                                    numberOfViews: 0,
                                    lastViewDate: nil,
                                    privateKeyUUID: keySet.id.uuidString,
                                    keyName: keySet.name,
                                    isFavorite: false,
                                    importedID: UUID(),
                                    disableFeedPreview: Bool.random()
                                )
                                queue.async() {
                                    newPhotos.append(newPhoto)
                                }
                            }
                            print(i)
                        }
                    }
                    
                    for z in 0 ..< 400 {
                        group.addTask {
                            let isLocal = Bool.random()
                            let keySet = isLocal ? KeychainKeys.shared.personalKey : self.fakeImportKeyDataSet
                            let video = videos.randomElement()
                            let url = Bundle.main.url(forResource: video, withExtension: "")!
                            let data = try! Data(contentsOf: url)
                            let encryptedData = try! PrivateKeyStuff.encryptUsing(data: data, keyDataSet: keySet)
                            let fileName = try! VideoEncryption.saveVideoFileInDocuemnts(data: encryptedData)
                            
                            let newPhoto = Photo(
                                id: UUID(),
                                imageData: nil,
                                savedDate: Calendar.current.date(byAdding: .day, value: -(Int.random(in: 0..<40)), to: Date()),
                                takenBy: nil,
                                takenDate:  Calendar.current.date(byAdding: .day, value: -(Int.random(in: 0..<40)), to: Date())!,
                                isVideo: true,
                                videoFileName: fileName,
                                localImage: isLocal,
                                allowedNumberOfViews: -1,
                                screenShotsAllowed: true,
                                numberOfViews: 0,
                                lastViewDate: nil,
                                privateKeyUUID: keySet.id.uuidString,
                                keyName: keySet.name,
                                isFavorite: false,
                                importedID: UUID(),
                                disableFeedPreview: Bool.random()
                            )
                            queue.async() {
                                newPhotos.append(newPhoto)
                            }
                            print(fileName)
                        }
                    }
                }
                for photo in newPhotos.shuffled() {
                    PhotosDBActor.shared.modelContainer.mainContext.insert(photo)
                }
                try! PhotosDBActor.shared.modelContainer.mainContext.save()
                print("new photos counts \(newPhotos.count)")
                print("*************** TEST DATA: Complete ***************")
                completion()
            }
        } catch {
            print(error)
        }
    }
}
