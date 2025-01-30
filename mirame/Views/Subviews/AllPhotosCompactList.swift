//
//  AllPhotosCompactList.swift
//  mirame
//
//  Created by Trey Tartt on 1/30/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import SwiftUI

struct AllPhotosCompactList: View {
    @Binding var selectMultiple: Bool
    @Binding var selectedIDs: [UUID]
    @Binding var viewType: AllPhotosViewType
    @Binding var photoToShow: PhotoToShow?
    var photos: [Photo]
    
    var body: some View {
        List {
            ForEach(photos) { photo in
                HStack {
                    PhotoDetailView(photo: photo)
                        .cornerRadius(8)
                        .border(.red, width: (selectMultiple && selectedIDs.contains(photo.photoID)) ? 4 : 0)
                }
                .contentShape(Rectangle())
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
        }
    }
}

//#Preview {
//    AllPhotosCompactList()
//}
