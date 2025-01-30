//
//  AllPhotosView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/25/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//

import SwiftUI
import SneakyCamPackage
import ScreenShield
import PhotosUI
import SwiftData
import SneakySync

struct AllPhotosView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var photos: [Photo]
        
    @State var showKeys: Bool = false
    @State var photoToShow: PhotoToShow?
    @State var showTakeImage: Bool = false
    @State var showSettings: Bool = false
    @State var selectMultiple: Bool = false
    @State var selectedIDs: [UUID] = []
    @State var mediaType: AllPhotosFilterType = .All
    @State private var importImageItem = [PhotosPickerItem]()
    @State var showAlert: Bool = false
    @State var showSharePhotos: Bool = false
    @State var alertConfig: AlertConfig? {
        didSet {
            showAlert = alertConfig != nil
        }
    }
    
    @MainActor
    @State var scaledImages = [String : Image]()
    
    @AppStorage("viewType") var viewType: AllPhotosViewType = .Saved
    @AppStorage("layoutType") var layoutType: AllPhotosViewLayoutType = .list
    @AppStorage("sortBy") var sortBy: AllPhotosSortType = .DateSavedAsc
    
    var sortedPhotos: [Photo] {
        var filteredItems = [Photo]()
        
        filteredItems = photos.compactMap({ photo in
            if photo.videoFileName != nil || photo.imageData != nil {
                return photo
            }
            return nil
        })
        
        switch viewType {
        case .Taken:
            filteredItems = filteredItems.compactMap({ photo in
                if let localImage = photo.localImage,
                   localImage {
                    return photo
                }
                return nil
            })
        case .Saved:
            filteredItems = filteredItems.compactMap({ photo in
                if let localImage = photo.localImage,
                   !localImage {
                    return photo
                }
                return nil
            })
        case .favorites:
            filteredItems = filteredItems.compactMap({ photo in
                if let isFavorite = photo.isFavorite,
                   isFavorite {
                    return photo
                }
                return nil
            })
        }
        
        switch mediaType {
        case .Photo:
            filteredItems = filteredItems.compactMap({ photo in
                if let isVideo = photo.isVideo,
                   !isVideo {
                    return photo
                }
                return nil
            })
        case .Video:
            filteredItems = filteredItems.compactMap({ photo in
                if let isVideo = photo.isVideo,
                   isVideo {
                    return photo
                }
                return nil
            })
        case .All:
            break
        }
                
        switch sortBy {
        case .DateSavedAsc:
            filteredItems = filteredItems.sorted { $0.savedDate ?? Date() < $1.savedDate ?? Date() }
        case .DateSavedDesc:
            filteredItems = filteredItems.sorted { $0.savedDate ?? Date() > $1.savedDate ?? Date() }
        case .DateTakenAsc:
            filteredItems = filteredItems.sorted { $0.takenDate ?? Date() < $1.takenDate ?? Date() }
        case .DateTakenDesc:
            filteredItems = filteredItems.sorted { $0.takenDate ?? Date() > $1.takenDate ?? Date() }
        case .viewCountAsc:
            filteredItems = filteredItems.sorted { $0.numberOfViews ?? 0 < $1.numberOfViews ?? 0 }
        case .viewCountDesc:
            filteredItems = filteredItems.sorted { $0.numberOfViews ?? 0 > $1.numberOfViews ?? 0 }
        }
        return filteredItems
    }
    
    var body: some View {
        VStack {
            AllPhotosHeaderView(
                viewType: $viewType,
                importImageItem: $importImageItem,
                showKeys: $showKeys,
                showSettings: $showSettings,
                showTakeImage: $showTakeImage)
                .padding([.leading, .trailing])
            
            viewPhotosTypePicker()
                .padding(.horizontal)
            
            if sortedPhotos.isEmpty {
                AllPhotosEmptyView(viewType: $viewType)
            } else {
                switch layoutType {
                case .list:
                    AllPhotosCompactList(
                        selectMultiple: $selectMultiple,
                        selectedIDs: $selectedIDs,
                        viewType: $viewType,
                        photoToShow: $photoToShow,
                        photos: sortedPhotos)
                case .preview:
                    AllPhotosPreviewList(
                        photoToShow: $photoToShow,
                        viewType: $viewType,
                        selectMultiple: $selectMultiple,
                        selectedIDs: $selectedIDs,
                        photos: sortedPhotos)
                        .protectScreenshot()
                }
                
                if viewType == .Taken && selectMultiple {
                    Button(action: {
                        showSharePhotos.toggle()
                    }, label: {
                        VStack {
                            Image(systemName: "shareplay")
                                .font(.title)
                            Text("\(selectedIDs.count) selected")
                                .font(.caption)
                        }
                        .contentShape(Rectangle())
                    })
                    Divider()
                }
            }
            AllPhotosFooterView(
                viewType: $viewType,
                mediaType: $mediaType,
                sortBy: $sortBy,
                layoutType: $layoutType,
                selectMultiple: $selectMultiple,
                viewRandom: {
                    if let photo = viewRandom() {
                        photoToShow = photo
                    }
                })
                .padding()
        }
        .sheet(isPresented: $showKeys) {
            print("Sheet dismissed!")
        } content: {
            AllKeysView()
        }
        .sheet(isPresented: $showSettings) {
            print("Sheet dismissed!")
        } content: {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showTakeImage) {
            print("Sheet dismissed!")
        } content: {
            NewPhotoView()
        }
        .sheet(item: $photoToShow,
               onDismiss: {},
               content: { thingy in
            ViewPhotoView(photo: thingy.photo, keyDataSet: thingy.keyDataSet)
                .onDisappear(perform: {
                    if DataBase.shared.deleteViewedPhotosIfNeeded() {
                        alertConfig = AlertConfig(
                            title: "Max number of views reached",
                            message: "Item has been deleted",
                            buttons: [])
                    }
                })
        })
        .sheet(isPresented: $showSharePhotos, content: {
            let photos = photos.filter( { selectedIDs.contains($0.photoID) })
            PicOptionsView(photos: Array(photos))
        })
        .onAppear() {
            ScreenShield.shared.protectFromScreenRecording()
            if DataBase.shared.deleteViewedPhotosIfNeeded() {
                alertConfig = AlertConfig(
                    title: "Max number of views reached",
                    message: "Item has been deleted",
                    buttons: [])
            }
        }
        .alert(alertConfig?.title ?? "",
               isPresented: $showAlert,
               actions: {
        }, message: {
            Text(alertConfig?.message ?? "")
        })
        .onChange(of: importImageItem) {
            parseSelectdImages()
        }
    }
    
    @ViewBuilder
    func viewPhotosTypePicker() -> some View {
        Picker("", selection: $viewType) {
            ForEach(AllPhotosViewType.allCases, id: \.self) {
                Text($0.description)
            }
        }
        .pickerStyle(.segmented)
    }

    func parseSelectdImages() {
        for item in importImageItem {
            item.loadTransferable(type: Data.self) { result in
                Task {
                    switch result {
                    case .success(let imageData):
                        if let imageData {
                            if let image = UIImage(data: imageData) {
                                let resized = image.compress(to: 3000)
                                if let resizedImage = UIImage(data: resized) {
                                    do {
                                        try await SaveDeleteContent.savePhoto(
                                            importedPhotoID: nil,
                                            image: resizedImage,
                                            keyDataSet: KeychainKeys.shared.personalKey,
                                            isLocal: true,
                                            allowedNumOfViews: -1,
                                            allowScreenShots: false,
                                            takenDate: Date(),
                                            disableFeedPreview: false)
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        } else {
                            print("No supported content type found.")
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        importImageItem = []
    }
    
    func viewRandom() -> PhotoToShow? {
        guard photos.count > 0 else { return nil }
        
        var returnPhoto: Photo? = nil
        var keyDataSet: KeyDataSet? = nil
        
        while returnPhoto == nil {
            if let photo = photos.randomElement()  {
                if let localImage = photo.localImage, localImage {
                    keyDataSet = KeychainKeys.shared.personalKey
                    returnPhoto = photo
                } else {
                    if let keyUUID = photo.privateKeyUUID,
                       let key = KeychainKeys.shared.getKeyWith(id: keyUUID),
                       let _ = photo.decrypt(withKey: key) {
                        keyDataSet = key
                        returnPhoto = photo
                    }
                }
            }
        }
        
        return PhotoToShow(
            id: UUID(),
            photo: returnPhoto!,
            keyDataSet: keyDataSet!)
    }
}
//
//#Preview {
//    AllPhotosView()
//}
