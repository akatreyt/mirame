//
//  KeychainKeys.swift
//  mirame-ios
//
//  Created by Trey Tartt on 7/25/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import Foundation
import KeychainSwift
import CommonCrypto
import SneakySync

class KeychainKeys: ObservableObject {
    // key that all taken photos are encrypted with
    let personalKeyValue = "KeyDataSetPersonalKey"
    
    // all keys either imported or generated
    var allKeysKeyValue = "KeyDataSetAllKeys"
    
    static let shared = KeychainKeys()
    
    @Published var allKeys = [KeyDataSet]()
    
    private var keychain : KeychainSwift{
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        return keychain
    }
    
    var personalKey : KeyDataSet {
        if let personalKeyData = keychain.getData(personalKeyValue),
           let model = try? JSONDecoder().decode(KeyDataSet.self, from: personalKeyData) {
            return model
        }
        let salt = PrivateKeyStuff.generateSalt()
        var newKey = PrivateKeyStuff.generateKeyPair(usingSalt: salt)
        newKey.name = "personal"
        if let data = try? JSONEncoder().encode(newKey) {
            keychain.set(data, forKey: personalKeyValue)
        }
        return newKey
    }
    
    private init() {
        self.allKeys = []
        resetAllKeys()
    }
    
    func resetAllKeys() {
        if let data = keychain.getData(allKeysKeyValue),
            let _allKeys = try? JSONDecoder().decode([KeyDataSet].self, from: data) {
            allKeys = _allKeys
        } else {
            allKeys = []
        }
    }
    
    func deleteAll() {
        keychain.delete(personalKeyValue)
        keychain.delete(allKeysKeyValue)
        resetAllKeys()
    }
    
    func deleteKey(key: KeyDataSet) throws {
        do{
            var _allKeys = allKeys //try getPrivateKeys(type: .all)
            if let idx = _allKeys.firstIndex(where: {
                $0.id == key.id
            }) {
                _allKeys.remove(at: idx)
            }
            
            let data = try JSONEncoder().encode(_allKeys)
            keychain.set(data, forKey: allKeysKeyValue)
            resetAllKeys()
        }catch{
            throw UIAlertTypes.errorDeletingAllPhotosForKey
        }
    }
    
    func saveLocally(key: KeyDataSet) throws {
        do {
            var _allKeys = allKeys
            
            if let idx = _allKeys.firstIndex(where: {
                $0.id == key.id
            }) {
                _allKeys[idx] = key
            } else {
                _allKeys.append(key)
            }
            
            let data = try JSONEncoder().encode(_allKeys)
            if !keychain.set(data, forKey: allKeysKeyValue) {
                fatalError()
            }
            resetAllKeys()
        } catch {
            throw error
        }
    }
//    
//    func getPrivateKeys(type: PrivateKeyType? = nil) throws -> [PrivateKey] {
//        switch type {
//        case .personal:
//            return allKeys.filter({ $0.imported == false })
//        case .all:
//            return allKeys
//        case .imported:
//            return allKeys.filter({ $0.imported == true })
//        case .none:
//            return []
//        }
//    }
    
    func getKeyWith(id: String) -> KeyDataSet? {
        allKeys.first(where: { $0.id.uuidString == id })
    }
}
