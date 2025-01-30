//
//  AllPhotosPreviewList.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/8/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import SwiftUI
import RealmSwift

struct AllPhotosPreviewList: View, Identifiable {
    var id: UUID = UUID()
    @ObservedObject var photoDataStore = PhotoDataStore.shared
    @ObservedObject var allPhotosViewModel: AllPhotosViewModel
    @Binding var photoToShow: PhotoToShow?
    
    @State var scaledImages: [String: Image] = [:]
    
    /*
     border(
     (selectMultiple && selectedIDs.contains(photo.id)) ? .red : Color(UIColor.systemBackground),
     width: (selectMultiple && selectedIDs.contains(photo.id)) ? 4 : 1)
     */
    
    var body: some View {
        List {
            ForEach(photoDataStore.photos, id: \.self) { photo in
                PhotoDetailViewPreview(photo: photo)
                    .border(.red, width: (allPhotosViewModel.selectMultiple && allPhotosViewModel.selectedIDs.contains(photo.id)) ? 4 : 0)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        if allPhotosViewModel.viewType == .Taken {
                            if allPhotosViewModel.selectMultiple {
                                if allPhotosViewModel.selectedIDs.contains(photo.id) {
                                    allPhotosViewModel.selectedIDs.removeAll(where: { $0 == photo.id })
                                } else {
                                    allPhotosViewModel.selectedIDs.append(photo.id)
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
        if let offset = offsets.first {
            do {
                let photo = PhotoDataStore.shared.photos[offset]
                try DataBase.deleteLocally(photo: photo)
            } catch {
                print(error)
            }
        }
    }
}
