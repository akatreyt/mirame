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
    @Binding var layoutType: AllPhotosViewLayoutType
    @Binding var photoToShow: PhotoToShow?
    @Binding var viewType: AllPhotosViewType
    @Binding var selectMultiple: Bool
    @Binding var selectedPhotosToShare: [Photo]
    
    
    @Binding var showStoreView: Bool
    @AppStorage("madeUnlockPurchase") private var madeUnlockPurchase = false
    @State private var showUnlockMessage = false
    
    @Binding private var sortOrder: SortDescriptor<Photo>
    @Binding private var predicate: Predicate<Photo>
    @Binding private var predicateStringTempUpdateThing: String
    
    @State private var photos: [Photo] = []
    @State private var filteredPhotos: [Photo] = []
    
    @Environment(\.modelContext) private var context
    @State private var dbTwo: PhotosDBActor?
    
    func getDBTWoActor() -> PhotosDBActor {
        guard let dbTwo else {
            let dbTwo = PhotosDBActor(modelContainer: context.container)
            self.dbTwo = dbTwo
            return dbTwo
        }
        return dbTwo
    }
    
    init(viewType: Binding<AllPhotosViewType>, selectMultiple: Binding<Bool>, selectedPhotosToShare: Binding<[Photo]>, showStoreView: Binding<Bool>, showUnlockMessage: Bool = false, photoToShow: Binding<PhotoToShow?>, sortOrder: Binding<SortDescriptor<Photo>>, predicate: Binding<Predicate<Photo>>, predicateStringTempUpdateThing: Binding<String>, layoutType: Binding<AllPhotosViewLayoutType>) {
        self._photoToShow = photoToShow
        self._viewType = viewType
        self._selectMultiple = selectMultiple
        self._selectedPhotosToShare = selectedPhotosToShare
        self._showStoreView = showStoreView
        self.showUnlockMessage = showUnlockMessage
        self._sortOrder = sortOrder
        self._predicate = predicate
        self._predicateStringTempUpdateThing = predicateStringTempUpdateThing
        self._layoutType = layoutType
        
        //        _photos = Query(filter: self.predicate, sort: [sortOrder])
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(Array(filteredPhotos.enumerated()), id: \.element) { index, photo in
                    switch layoutType {
                    case .preview:
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
                    case .list:
                        HStack {
                            PhotoDetailView(photo: photo)
                                .cornerRadius(8)
                                .border(.red, width: (selectMultiple && selectedPhotosToShare.contains(photo)) ? 4 : 0)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !madeUnlockPurchase && index != 0 {
                                showUnlockMessage = true
                            } else {
                                if viewType == .Taken {
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
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("AddedNewPhoto"))) { data in
            guard let userInfo = data.userInfo, let photo = userInfo["photo"] as? Photo else {
                return
            }
            photos.append(photo)
            filteredPhotos = try! photos.filter(self.predicate)
            filteredPhotos = filteredPhotos.sorted(using: self.sortOrder)
        }
        .task {
            photos = try! await getDBTWoActor().getAll() ?? []
            filteredPhotos = try! photos.filter(self.predicate)
            filteredPhotos = filteredPhotos.sorted(using: self.sortOrder)
        }
        .onChange(of: $sortOrder.wrappedValue) {
            filteredPhotos = filteredPhotos.sorted(using: self.sortOrder)
        }
        .onChange(of: $predicateStringTempUpdateThing.wrappedValue) {
            filteredPhotos = try! photos.filter(self.predicate)
            filteredPhotos = filteredPhotos.sorted(using: self.sortOrder)
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
    
    //    func delete(at offsets: IndexSet) {
    //        DataBase.shared.deleteLocally(photo: photos[offsets.first!])
    //    }
}







