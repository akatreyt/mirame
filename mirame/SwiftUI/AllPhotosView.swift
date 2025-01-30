//
//  AllPhotosView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/25/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//

import SwiftUI
import SneakyCamPackage
import Realm
import ScreenShield
import PhotosUI

struct AllPhotosView: View {
    @StateObject var viewModel: AllPhotosViewModel = .init()
    @ObservedObject var photoDataStore = PhotoDataStore.shared
    
    @State var showKeys: Bool = false
    @State var photoToShow: PhotoToShow?
    @State var showTakeImage: Bool = false
    @State var showSettings: Bool = false
    
    @State private var importImageItem = [PhotosPickerItem]()
    
    @State var alertConfig: AlertConfig? {
        didSet {
            showAlert = alertConfig != nil
        }
    }
    @State var showAlert: Bool = false
    
    @MainActor
    @State var scaledImages = [String : Image]()
    
    @State var showSharePhotos: Bool = false
    
    var body: some View {
        VStack {
            AllPhotosHeaderView(
                viewType: $viewModel.viewType,
                importImageItem: $importImageItem,
                showKeys: $showKeys,
                showSettings: $showSettings)
                .padding([.leading, .trailing])
            
            viewPhotosTypePicker()
                .padding(.horizontal)
            
            if photoDataStore.photos.isEmpty {
                AllPhotosEmptyView(viewType: $viewModel.viewType)
            } else {
                switch viewModel.layoutType {
                case .list:
                    AllPhotosCompactList(
                        selectMultiple: $viewModel.selectMultiple,
                        viewType: $viewModel.viewType,
                        photoToShow: $photoToShow)
                case .preview:
                    AllPhotosPreviewList(allPhotosViewModel: viewModel,
                                         photoToShow: $photoToShow)
                        .protectScreenshot()
                }
                
                if viewModel.viewType == .Taken && viewModel.selectMultiple {
                    Button(action: {
                        showSharePhotos.toggle()
                    }, label: {
                        VStack {
                            Image(systemName: "shareplay")
                                .font(.title)
                            Text("\(viewModel.selectedIDs.count) selected")
                                .font(.caption)
                        }
                        .contentShape(Rectangle())
                    })
                    Divider()
                }
            }
            AllPhotosFooterView(
                viewType: $viewModel.viewType,
                mediaType: $viewModel.mediaType,
                sortBy: $viewModel.sortBy,
                layoutType: $viewModel.layoutType,
                selectMultiple: $viewModel.selectMultiple,
                viewRandom: {
                    if let photo = viewModel.viewRandom() {
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
                    if DataBase.deleteViewedPhotosIfNeeded() {
                        alertConfig = AlertConfig(
                            title: "Max number of views reached",
                            message: "Item has been deleted",
                            buttons: [])
                    }
                })
        })
        .sheet(isPresented: $showSharePhotos, content: {
            let photos = photoDataStore.photos.filter( { viewModel.selectedIDs.contains($0.id) })
            PicOptionsView(photos: Array(photos))
        })
        .onAppear() {
            ScreenShield.shared.protectFromScreenRecording()
            if DataBase.deleteViewedPhotosIfNeeded() {
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
        Picker("", selection: $viewModel.viewType) {
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
}

#Preview {
    AllPhotosView()
}
