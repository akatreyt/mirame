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
    func populateTestData() async {
        DataBase.shared.deleteAll()
        KeychainKeys.shared.deleteAll()
        
        try! KeychainKeys.shared.saveLocally(key: fakeImportKeyDataSet)
        
        var isLocal = false
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
            var i = 0
            for file in files {
                if file.hasSuffix("jpg") {
                    let url = Bundle.main.url(forResource: file, withExtension: "")!
                    let data = try! Data(contentsOf: url)
                    let image = UIImage(data: data)!
                    await saveImage(image, isLocal: isLocal)
                    isLocal.toggle()
                    i += 1
                    print("added \(i)")
                    if i > 50 {
                        return
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func saveImage(_ image: UIImage, isLocal: Bool) async {
        if isLocal {
            let _ = try! await SaveDeleteContent.savePhoto(importedPhotoID: UUID(),
                                                           image: image,
                                                           keyDataSet: KeychainKeys.shared.personalKey,
                                                           isLocal: true,
                                                           allowedNumOfViews: -1,
                                                           allowScreenShots: false,
                                                           takenDate: Calendar.current.date(byAdding: .day, value: -(Int.random(in: 0..<40)), to: Date())!,
                                                           disableFeedPreview: Bool.random())
        } else {
            let _ = try! await SaveDeleteContent.savePhoto(importedPhotoID: UUID(),
                                                           image: image,
                                                           keyDataSet: fakeImportKeyDataSet,
                                                           isLocal: false,
                                                           allowedNumOfViews: Int.random(in: 1..<4),
                                                           allowScreenShots: false,
                                                           takenDate: Calendar.current.date(byAdding: .day, value: -(Int.random(in: 0..<40)), to: Date())!,
                                                           disableFeedPreview: Bool.random())
        }
    }
}
