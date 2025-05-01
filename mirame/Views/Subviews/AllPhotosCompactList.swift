//
//  AllPhotosCompactList.swift
//  mirame
//
//  Created by Trey Tartt on 1/30/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import SwiftUI
import SwiftDataPager

struct AllPhotosCompactList: View {
    @Binding var selectMultiple: Bool
    @Binding var selectedIDs: [UUID]
    @Binding var viewType: AllPhotosViewType
    @Binding var photoToShow: PhotoToShow?
    @PagedQuery() private var photos: [Photo]
    
    @Binding var showStoreView: Bool
    @AppStorage("isUnlocked") private var isUnlocked = false
    @State private var showUnlockMessage = false
    
    init(selectMultiple: Binding<Bool>, selectedIDs: Binding<[UUID]>, viewType: Binding<AllPhotosViewType>, photoToShow: Binding<PhotoToShow?>, showStoreView: Binding<Bool>, isUnlocked: Bool = false, showUnlockMessage: Bool = false, sortOrder: SortDescriptor<Photo>, predicate: Predicate<Photo>) {
        self._selectMultiple = selectMultiple
        self._selectedIDs = selectedIDs
        self._viewType = viewType
        self._photoToShow = photoToShow
        self._showStoreView = showStoreView
        self.isUnlocked = isUnlocked
        self.showUnlockMessage = showUnlockMessage
        
        _photos = PagedQuery(
            fetchLimit: 20,
            sortDescriptors: [sortOrder],
            filterPredicate: predicate,
            logger: .default
        )
    }
    
    var body: some View {
        List {
            ForEach(Array(photos.enumerated()), id: \.element) { index, photo in
                HStack {
                    PhotoDetailView(photo: photo)
                        .cornerRadius(8)
                        .border(.red, width: (selectMultiple && selectedIDs.contains(photo.photoID)) ? 4 : 0)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isUnlocked && index != 0 {
                        showUnlockMessage = true
                    } else {
                        if viewType == .Taken {
                            if selectMultiple {
                                if selectedIDs.contains(photo.photoID) {
                                    selectedIDs.removeAll(where: { $0 == photo.photoID })
                                } else {
                                    selectedIDs.append(photo.photoID)
                                }
                            } else {
                                photoToShow = PhotoToShow(
                                    id: UUID(),
                                    photo: photo,
                                    keyDataSet: KeychainKeys.shared.personalKey)
                            }
                        } else {
                            if let keyUUID = photo.privateKeyUUID,
                               let key = KeychainKeys.shared.getKeyWith(id: keyUUID)  {
                                photoToShow = PhotoToShow(id: UUID(), photo: photo, keyDataSet: key)
                            }
                        }
                    }
                }
            }
        }
        .alert("Subscribe to mírame to view all photos?", isPresented: $showUnlockMessage) {
            Button("Yes", role: .none) {
                showStoreView = true
            }
            
            Button("No", role: .cancel) { }
        }
    }
}

//#Preview {
//    AllPhotosCompactList()
//}
