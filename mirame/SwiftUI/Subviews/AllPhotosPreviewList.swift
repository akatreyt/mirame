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
    var photos: [Photo]
    
    var scaledImages: [String: Image] = [:]
    
    /*
     border(
     (selectMultiple && selectedIDs.contains(photo.id)) ? .red : Color(UIColor.systemBackground),
     width: (selectMultiple && selectedIDs.contains(photo.id)) ? 4 : 1)
     */
    
    var body: some View {
        List {
            ForEach(photos, id: \.self) { photo in
                PhotoDetailViewPreview(photo: photo)
                    .border(.red, width: (selectMultiple && selectedIDs.contains(photo.photoID)) ? 4 : 0)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                    .listRowSeparator(.hidden)
                    .onTapGesture {
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
            .onDelete(perform: delete)
        }
        .frame( maxWidth: .infinity)
        .edgesIgnoringSafeArea(.all)
        .listStyle(.grouped)
        .contentMargins(.top, 0)
    }
    
    func delete(at offsets: IndexSet) {
        DataBase.shared.deleteLocally(photo: photos[offsets.first!])
    }
}
