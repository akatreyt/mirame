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
    
    @State private var sortOrder = SortDescriptor<Photo> (\Photo.numberOfViews, order: .reverse)
    @State private var predicate = #Predicate<Photo> { $0.videoFileName != nil || $0.imageData != nil }
    
    @State var showKeys: Bool = false
    @State var showStoreView: Bool = false
    @State var photoToShow: PhotoToShow?
    @State var showTakeImage: Bool = false
    @State var showSettings: Bool = false
    @State var selectMultiple: Bool = false
    @State var selectedPhotosToShare: [Photo] = []
    @State private var currentFilterID = "thisIsRandom"

    @State private var importImageItem = [PhotosPickerItem]()
    @State var showAlert: Bool = false
    @State var showSharePhotos: Bool = false
    @State var alertConfig: AlertConfig? {
        didSet {
            showAlert = alertConfig != nil
        }
    }
    

    @AppStorage("madeUnlockPurchase") private var madeUnlockPurchase = false
    @AppStorage("viewType") var viewType: AllPhotosViewType = .Saved
    @AppStorage("layoutType") var layoutType: AllPhotosViewLayoutType = .list
    @AppStorage("sortBy") var sortBy: AllPhotosSortType = .DateSavedAsc
    @AppStorage("mediaType") var mediaType: AllPhotosFilterType = .All
    
    func updatePhotos(sortOrder: SortDescriptor<Photo>, predicate: Predicate<Photo>) {
        self.sortOrder = sortOrder
        self.predicate = predicate
    }
    
    var subscriptionGroupID: String {
#if targetEnvironment(simulator)
        return "54DA0067"
#else
        return "21632132"
#endif
    }
    
    var sortedPhotos: (SortDescriptor<Photo>, Predicate<Photo>) {
        var sortOrder = SortDescriptor(\Photo.takenDate, order: .forward)
        var predicate = #Predicate<Photo> { $0.videoFileName != nil || $0.imageData != nil }
        
        switch self.sortBy {
        case .DateSavedAsc:
            sortOrder = SortDescriptor(\Photo.savedDate, order: .forward)
        case .DateSavedDesc:
            sortOrder = SortDescriptor(\Photo.savedDate, order: .reverse)
        case .DateTakenAsc:
            sortOrder = SortDescriptor(\Photo.takenDate, order: .forward)
        case .DateTakenDesc:
            sortOrder = SortDescriptor(\Photo.takenDate, order: .reverse)
        case .viewCountAsc:
            sortOrder = SortDescriptor(\Photo.numberOfViews, order: .forward)
        case .viewCountDesc:
            sortOrder = SortDescriptor(\Photo.numberOfViews, order: .reverse)
        }
        
        var wantsVideos = false
        var wantsPhotos = false
        var wantsLocal = false
        var wantsImported = false
        var wantsFavorites = false
        
        switch (self.viewType, self.mediaType) {
        case (.Saved, .Photo):
            wantsPhotos = true
            wantsImported = true
        case (.Saved, .Video):
            wantsVideos = true
            wantsImported = true
        case (.Saved, .All):
            wantsVideos = true
            wantsPhotos = true
            wantsImported = true
            
        case (.Taken, .Photo):
            wantsPhotos = true
            wantsLocal = true
        case (.Taken, .Video):
            wantsVideos = true
            wantsLocal = true
        case (.Taken, .All):
            wantsVideos = true
            wantsPhotos = true
            wantsLocal = true
            
        case (.favorites, .Photo):
            wantsPhotos = true
            wantsFavorites = true
            wantsImported = true
            wantsLocal = true
        case (.favorites, .Video):
            wantsVideos = true
            wantsFavorites = true
            wantsImported = true
            wantsLocal = true
        case (.favorites, .All):
            wantsVideos = true
            wantsPhotos = true
            wantsFavorites = true
            wantsImported = true
            wantsLocal = true
        }
        
        predicate = #Predicate<Photo> {
            ($0.videoFileName != nil || $0.imageData != nil) &&
            ((wantsPhotos != wantsVideos) ? ($0.isVideo ?? false) == wantsVideos : true) &&
            ($0.isFavorite == wantsFavorites ? true : false) &&
            (($0.localImage ?? false) == wantsImported ? false : true)
        }
        
        currentFilterID = String(wantsLocal ? 1 : 0) + String(wantsImported ? 1 : 0) + String(wantsFavorites ? 1 : 0) + String(wantsPhotos ? 1 : 0) + String(wantsVideos ? 1 : 0) + sortBy.rawValue
        
        return (sortOrder, predicate)
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
            
            //                AllPhotosEmptyView(viewType: $viewType)
            AllPhotosList(
                viewType: $viewType,
                selectMultiple: $selectMultiple,
                selectedPhotosToShare: $selectedPhotosToShare,
                showStoreView: $showStoreView,
                photoToShow: $photoToShow,
                sortOrder: $sortOrder,
                predicate: $predicate,
                predicateStringTempUpdateThing: $currentFilterID,
                layoutType: $layoutType)
            .protectScreenshot()
            
            if viewType == .Taken && selectMultiple {
                Button(action: {
                    showSharePhotos.toggle()
                }, label: {
                    VStack {
                        Image(systemName: "shareplay")
                            .font(.title)
                        Text("\(selectedPhotosToShare.count) selected")
                            .font(.caption)
                    }
                    .contentShape(Rectangle())
                })
                .padding(.top, 5)
                
                Divider()
            }
            
            
            Divider()
                .padding(.top, -8)
            
            AllPhotosFooterView(
                viewType: $viewType,
                mediaType: $mediaType,
                sortBy: $sortBy,
                layoutType: $layoutType,
                selectMultiple: $selectMultiple,
                isUnlocked: $madeUnlockPurchase,
                viewRandom: {
                    if let photo = viewRandom() {
                        photoToShow = photo
                    }
                })
            .padding()
        }
        .onAppear {
            let sorted = sortedPhotos
            updatePhotos(sortOrder: sorted.0, predicate: sorted.1)
        }
        .sheet(isPresented: $showKeys, content: {
            AllKeysView()
        })
        .sheet(isPresented: $showSettings, content: {
            SettingsView()
        })
        .fullScreenCover(isPresented: $showTakeImage, content: {
            NewPhotoView()
        })
        .sheet(isPresented: $showStoreView, content: {
            SubscriptionView()
        })
        .sheet(item: $photoToShow,
               onDismiss: {},
               content: { thingy in
            ViewPhotoView(photo: thingy.photo, keyDataSet: thingy.keyDataSet)
                .onDisappear(perform: {
                    if DataBase.shared.deleteViewedPhotosIfNeeded(photos: [thingy.photo]) {
                        alertConfig = AlertConfig(
                            title: "Max number of views reached",
                            message: "Item has been deleted",
                            buttons: [])
                    }
                })
        })
        .sheet(isPresented: $showSharePhotos, content: {
            PicOptionsView(photos: selectedPhotosToShare)
        })
        //        .onAppear() {
        //            ScreenShield.shared.protectFromScreenRecording()
        //            if DataBase.shared.deleteViewedPhotosIfNeeded(photos: photos) {
        //                alertConfig = AlertConfig(
        //                    title: "Max number of views reached",
        //                    message: "Item has been deleted",
        //                    buttons: [])
        //            }
        //
        //            if !Toggles.isIapEnabled {
        //                isUnlocked = true
        //            }
        //        }
        .alert(alertConfig?.title ?? "",
               isPresented: $showAlert,
               actions: {
        }, message: {
            Text(alertConfig?.message ?? "")
        })
        .onChange(of: importImageItem) {
            parseSelectdImages()
        }
        .onChange(of: $sortBy.wrappedValue) {
            let sorted = sortedPhotos
            updatePhotos(sortOrder: sorted.0, predicate: sorted.1)
        }
        .onChange(of: $viewType.wrappedValue) {
            let sorted = sortedPhotos
            updatePhotos(sortOrder: sorted.0, predicate: sorted.1)
        }
        .onChange(of: $mediaType.wrappedValue) {
            let sorted = sortedPhotos
            updatePhotos(sortOrder: sorted.0, predicate: sorted.1)
        }
        .subscriptionStatusTask(for: subscriptionGroupID) { taskState in
            if !Toggles.isIapEnabled { return }
            
            if case .loading = taskState { return }
            
            if let value = taskState.value {
                madeUnlockPurchase = value.map(\.state).contains { [.subscribed, .inBillingRetryPeriod, .inGracePeriod].contains($0) } == true
            } else {
                madeUnlockPurchase = false
            }
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
        return nil
        
        //        var returnPhoto: Photo? = nil
        //        var keyDataSet: KeyDataSet? = nil
        //
        //        while returnPhoto == nil {
        //            if let photo = photos.randomElement()  {
        //                if let localImage = photo.localImage, localImage {
        //                    keyDataSet = KeychainKeys.shared.personalKey
        //                    returnPhoto = photo
        //                } else {
        //                    if let keyUUID = photo.privateKeyUUID,
        //                       let key = KeychainKeys.shared.getKeyWith(id: keyUUID),
        //                       let _ = photo.decrypt(withKey: key) {
        //                        keyDataSet = key
        //                        returnPhoto = photo
        //                    }
        //                }
        //            }
        //        }
        //
        //        return PhotoToShow(
        //            id: UUID(),
        //            photo: returnPhoto!,
        //            keyDataSet: keyDataSet!)
    }
}
//
//#Preview {
//    AllPhotosView()
//}
