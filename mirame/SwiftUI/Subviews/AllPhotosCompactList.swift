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
    @State var selectedIDs = [String]()
    @Binding var viewType: AllPhotosViewType
    @Binding var photoToShow: PhotoToShow?
    @ObservedObject var photoDataStore = PhotoDataStore.shared
    
    var body: some View {
        List {
            ForEach(photoDataStore.photos) { photo in
                HStack {
                    PhotoDetailView(photo: photo)
                        .cornerRadius(8)
                        .border(.red, width: (selectMultiple && selectedIDs.contains(photo.id)) ? 4 : 0)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewType == .Taken {
                        if selectMultiple {
                            if selectedIDs.contains(photo.id) {
                                selectedIDs.removeAll(where: { $0 == photo.id })
                            } else {
                                selectedIDs.append(photo.id)
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
