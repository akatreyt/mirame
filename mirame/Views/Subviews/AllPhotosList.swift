//
//  AllPhotosPreviewList.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/8/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import SwiftUI
import SwiftData


struct AllPhotosList: View {
    @Binding var layoutType: AllPhotosViewLayoutType
    @Binding var photoToShow: PhotoToShow?
    @Binding var viewType: AllPhotosViewType
    @Binding var selectMultiple: Bool
    @Binding var selectedPhotosToShare: [Photo]
    @Binding private var sortOrder: SortDescriptor<Photo>
    @Binding private var predicate: Predicate<Photo>
    @Binding private var predicateStringTempUpdateThing: String
    @Binding var showStoreView: Bool

    @State private var showUnlockMessage = false
    @State private var photos: [Photo] = []
    @State private var filteredPhotos: [Photo] = []
    @State private var dbTwo: PhotosDBActor?
    @State private var isLoading = true
    
    @Environment(\.modelContext) private var context
    @AppStorage("madeUnlockPurchase") private var madeUnlockPurchase = false
    
    func getDBTWoActor() -> PhotosDBActor {
        guard let dbTwo else {
            let dbTwo = PhotosDBActor(modelContainer: DataBase.shared.sharedModelContainer)
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
    }
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.top, 100)
                    .scaleEffect(1.5, anchor: .center)
                
            } else if !isLoading && photos.isEmpty {
                AllPhotosEmptyView(viewType: $viewType)
            } else {
                LazyVStack {
                    ForEach(Array(filteredPhotos.enumerated()), id: \.element) { index, photo in
                        switch layoutType {
                        case .preview:
                            PhotoDetailViewPreview(photo: photo, isLocked: !madeUnlockPurchase && index != 0)
                                .cornerRadius(8)
                                .border(.red, width: (selectMultiple && selectedPhotosToShare.contains(photo)) ? 4 : 0)
                                .onTapGesture{
                                    rowTapped(photo: photo, index: index)
                                }
                            
                        case .list:
                            PhotoDetailView(photo: photo)
                                .cornerRadius(8)
                                .border(.red, width: (selectMultiple && selectedPhotosToShare.contains(photo)) ? 4 : 0)
                                .onTapGesture{
                                    rowTapped(photo: photo, index: index)
                                }
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listRowSeparator(.hidden)
            }
        }
        .padding(.horizontal, 8)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("AddedNewPhoto"))) { data in
            guard let userInfo = data.userInfo, let photo = userInfo["photo"] as? Photo else {
                return
            }
            
            withAnimation(.easeOut(duration: 0.25)) {
                photos.append(photo)
                filteredPhotos = try! photos.filter(self.predicate)
                filteredPhotos = filteredPhotos.sorted(using: self.sortOrder)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DeletedPhoto"))) { data in
            guard let userInfo = data.userInfo, let photo = userInfo["photo"] as? Photo else {
                return
            }
            
            withAnimation(.easeOut(duration: 0.25)) {
                Task {
                    await dbTwo?.deletePhoto(photo: photo)
                }
                filteredPhotos = try! photos.filter(self.predicate)
                filteredPhotos = filteredPhotos.sorted(using: self.sortOrder)
            }
        }
        .task {
            do {
                photos = try await getDBTWoActor().getAll()
                withAnimation(.easeIn(duration: 0.25)) {
                    filteredPhotos = try! photos.filter(self.predicate)
                    filteredPhotos = filteredPhotos.sorted(using: self.sortOrder)
                    isLoading = false
                }
            } catch {
                
            }
        }
        .onChange(of: $sortOrder.wrappedValue) {
            withAnimation(.easeIn(duration: 0.25)) {
                filteredPhotos = filteredPhotos.sorted(using: self.sortOrder)
            }
        }
        .onChange(of: $predicateStringTempUpdateThing.wrappedValue) {
            withAnimation(.easeIn(duration: 0.25)) {
                filteredPhotos = try! photos.filter(self.predicate)
                filteredPhotos = filteredPhotos.sorted(using: self.sortOrder)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .contentMargins(.top, 0)
        .alert("Subscribe to mírame to view all photos?", isPresented: $showUnlockMessage) {
            Button("Yes", role: .none) {
                showStoreView = true
            }
            
            Button("No", role: .cancel) { }
        }
    }
    
    func rowTapped(photo: Photo, index: Int) {
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
    
    func delete(at offsets: IndexSet) {
        DataBase.shared.deleteLocally(photo: photos[offsets.first!])
    }
}







