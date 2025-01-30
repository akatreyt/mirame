//
//  AllPhotosViewModel.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/29/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//
import Foundation
import RealmSwift
import SwiftUI

class AllPhotosViewModel: ObservableObject {
    
    @Published var selectMultiple: Bool = false
    @Published var selectedIDs: [String] = []
    
    @AppStorage("layoutType") var layoutType: AllPhotosViewLayoutType = .list
    
    @AppStorage("sortBy") var sortBy: AllPhotosSortType = .DateSavedAsc {
        didSet {
            photosSorted()
        }
    }
    
    var mediaType: AllPhotosFilterType = .All {
        didSet {
            photosSorted()
        }
    }
    
    @AppStorage("sortBy") var viewType: AllPhotosViewType = .Saved {
        didSet {
            photosSorted()
        }
    }
    
    init () {
        photosSorted()
    }
    
    func viewRandom() -> PhotoToShow? {
        if let photo = PhotoDataStore.shared.photos.randomElement()  {
            if photo.localImage == 1 {
                return PhotoToShow(
                    id: UUID(),
                    photo: photo,
                    keyDataSet: KeychainKeys.shared.personalKey)
            } else {
                if let keyUUID = photo.privateKeyUUID,
                   let key = KeychainKeys.shared.getKeyWith(id: keyUUID),
                   let _ = photo.decrypt(withKey: key) {
                    return PhotoToShow(
                        id: UUID(),
                        photo: photo,
                        keyDataSet: key)
                }
            }
        }
        return nil
    }
    
    func photosSorted() {
        var filterString = [String]()
        filterString.append(viewType.dbString)
        filterString.append(mediaType.dbString)
        
        var string = filterString.joined(separator: " && ")
        
        if string.isEmpty {
            string = DataBase.haveDataFilter
        } else {
            string += " && \(DataBase.haveDataFilter)"
        }
        
        PhotoDataStore.shared.setFilter(filter: string)
        
        switch sortBy {
        case .DateSavedAsc:
            PhotoDataStore.shared.setSortDesctriptors(SortDescriptor(keyPath: "savedDate", ascending: true))
            case .DateSavedDesc:
            PhotoDataStore.shared.setSortDesctriptors(SortDescriptor(keyPath: "savedDate", ascending: false))
        case .DateTakenAsc:
            PhotoDataStore.shared.setSortDesctriptors(SortDescriptor(keyPath: "takenDate", ascending: true))
        case .DateTakenDesc:
            PhotoDataStore.shared.setSortDesctriptors(SortDescriptor(keyPath: "takenDate", ascending: false))
        case .viewCountAsc:
            PhotoDataStore.shared.setSortDesctriptors(SortDescriptor(keyPath: "numberOfViews", ascending: true))
        case .viewCountDesc:
            PhotoDataStore.shared.setSortDesctriptors(SortDescriptor(keyPath: "numberOfViews", ascending: false))
        }
    }
}
