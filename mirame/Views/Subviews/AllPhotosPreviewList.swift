//
//  AllPhotosPreviewList.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/8/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import SwiftUI
import SwiftDataPager

struct AllPhotosPreviewList: View {
    @Binding var photoToShow: PhotoToShow?
    @Binding var viewType: AllPhotosViewType
    @Binding var selectMultiple: Bool
    @Binding var selectedIDs: [UUID]
    @PagedQuery var photos: [Photo]
    
    @Binding var showStoreView: Bool
    @AppStorage("isUnlocked") private var isUnlocked = false
    @State private var showUnlockMessage = false
    
    @State private var sortOrder: SortDescriptor<Photo>
    @State private var predicate: Predicate<Photo>
    
    init(viewType: Binding<AllPhotosViewType>, selectMultiple: Binding<Bool>, selectedIDs: Binding<[UUID]>, showStoreView: Binding<Bool>, showUnlockMessage: Bool = false, photoToShow: Binding<PhotoToShow?>, sortOrder: SortDescriptor<Photo>, predicate: Predicate<Photo>) {
        self._photoToShow = photoToShow
        self._viewType = viewType
        self._selectMultiple = selectMultiple
        self._selectedIDs = selectedIDs
        self._showStoreView = showStoreView
        self.showUnlockMessage = showUnlockMessage
        self.sortOrder = sortOrder
        self.predicate = predicate
        
        print(predicate.debugDescription)
        
        _photos = PagedQuery(
            fetchLimit: 30,
            sortDescriptors: [sortOrder],
            filterPredicate: predicate, // #Predicate<Photo> { ($0.isFavorite ?? false) == true },
            logger: .default
        )
    }

    /*
     border(
     (selectMultiple && selectedIDs.contains(photo.id)) ? .red : Color(UIColor.systemBackground),
     width: (selectMultiple && selectedIDs.contains(photo.id)) ? 4 : 1)
     */
    
    var body: some View {
        VStack {
            Button(action: {
                $photos.reset()
            }, label: {
                Text("text")
            })
            
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
                        .onPaginationThreshold(threshold: 10, item: photo, in: $photos)
//                        .onLoadMore(item: photo, in: $photos)
                }
                .onDelete(perform: delete)
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
