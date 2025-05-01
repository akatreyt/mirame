//
//  AllPhotosPreviewList.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/8/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import SwiftUI
import SwiftData

struct AllPhotosPreviewList: View {
    @Binding var photoToShow: PhotoToShow?
    @Binding var viewType: AllPhotosViewType
    @Binding var selectMultiple: Bool
    @Binding var selectedPhotosToShare: [Photo]
    @Query var photos: [Photo]
    
    @Binding var showStoreView: Bool
    @AppStorage("madeUnlockPurchase") private var madeUnlockPurchase = false
    @State private var showUnlockMessage = false
    
    @State private var sortOrder: SortDescriptor<Photo>
    @State private var predicate: Predicate<Photo>
    
    init(viewType: Binding<AllPhotosViewType>, selectMultiple: Binding<Bool>, selectedPhotosToShare: Binding<[Photo]>, showStoreView: Binding<Bool>, showUnlockMessage: Bool = false, photoToShow: Binding<PhotoToShow?>, sortOrder: SortDescriptor<Photo>, predicate: Predicate<Photo>) {
        self._photoToShow = photoToShow
        self._viewType = viewType
        self._selectMultiple = selectMultiple
        self._selectedPhotosToShare = selectedPhotosToShare
        self._showStoreView = showStoreView
        self.showUnlockMessage = showUnlockMessage
        self.sortOrder = sortOrder
        self.predicate = predicate
        
        _photos = Query(filter: self.predicate, sort: [sortOrder])
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(photos, id: \.id) { photo in
                    Text(photo.id?.uuidString ?? "")
                }
            }
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

/*
 VStack {
 List {
 ForEach(Array(photos.enumerated()), id: \.element) { index, photo in
 PhotoDetailViewPreview(photo: photo, isLocked: !madeUnlockPurchase && index != 0)
 .border(.red, width: (selectMultiple && selectedPhotosToShare.contains(photo)) ? 4 : 0)
 .cornerRadius(8)
 .contentShape(Rectangle())
 .listRowSeparator(.hidden)
 .onTapGesture {
 if !madeUnlockPurchase && index != 0 {
 showUnlockMessage = true
 } else {
 if let local = photo.localImage, local {
 if selectMultiple {
 if selectedPhotosToShare.contains(photo) {
 selectedPhotosToShare.removeAll(where: { $0 == photo })
 } else {
 selectedPhotosToShare.append(photo)
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
 .onPaginationThreshold(threshold: 10, item: photo, in: $photos)
 //                        .onLoadMore(item: photo, in: $photos)
 }
 .onDelete(perform: delete)
 }
 */
