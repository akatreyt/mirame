//
//  AllPhotosPreviewList.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/8/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import SwiftUI

struct AllPhotosPreviewList: View {
    @Binding var photoToShow: PhotoToShow?
    @Binding var viewType: AllPhotosViewType
    @Binding var selectMultiple: Bool
    @Binding var selectedIDs: [UUID]
    
    @Binding var showStoreView: Bool
    @AppStorage("isUnlocked") private var isUnlocked = false
    @State private var showUnlockMessage = false
    
    var photos: [Photo]
    
    var scaledImages: [String: Image] = [:]
    
    /*
     border(
     (selectMultiple && selectedIDs.contains(photo.id)) ? .red : Color(UIColor.systemBackground),
     width: (selectMultiple && selectedIDs.contains(photo.id)) ? 4 : 1)
     */
    
    var body: some View {
        List {
            ForEach(Array(photos.enumerated()), id: \.element) { index, photo in
                PhotoDetailViewPreview(photo: photo, isLocked: !isUnlocked && index != 0)
                    .border(.red, width: (selectMultiple && selectedIDs.contains(photo.photoID)) ? 4 : 0)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        if !isUnlocked && index != 0 {
                            showUnlockMessage = true
                        } else {
                            if let local = photo.localImage, local {
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
            .onDelete(perform: delete)
        }
        .frame( maxWidth: .infinity)
        .edgesIgnoringSafeArea(.all)
        .listStyle(.grouped)
        .contentMargins(.top, 0)
        .alert("Subscribe to mírame to view all photos?", isPresented: $showUnlockMessage) {
            Button("Yes", role: .none) {
                showStoreView = true
            }
            
            Button("No", role: .cancel) { }
        }
    }
    
    func delete(at offsets: IndexSet) {
        DataBase.shared.deleteLocally(photo: photos[offsets.first!])
    }
}
