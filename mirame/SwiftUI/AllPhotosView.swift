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
            header()
                .padding([.leading, .trailing])
            
            viewPhotosTypePicker()
                .padding(.horizontal)
            
            if photoDataStore.photos.isEmpty {
                if viewModel.viewType == .Saved {
                    Text("No photos found.")
                        .padding()
                    
                    Text("Find someone to share photos with and share a key by tapping the \(Image(systemName: "key")), located on the top right, to share keys")
                        .multilineTextAlignment(.leading)
                        .padding()
                }
                if viewModel.viewType == .Taken {
                    Text("You havent taken any photos yet")
                        .padding()
                    
                    Text("Tap \(Image(systemName: "camera")), located on the top left, to take a few")
                        .multilineTextAlignment(.leading)
                        .padding()
                }
                if viewModel.viewType == .favorites {
                    Text("No favorites")
                        .padding()
                    
                    Text("Once you favorite some photos, by tapping on the \(Image(systemName: "heart")) when viewing the photo, they will be located here for quick access")
                        .multilineTextAlignment(.leading)
                        .padding()
                }
                Spacer()
                if viewModel.viewType == .Saved {
                    Text("When you have some photos use the options on the bottom of the screen to filter photos or vidoes, sort the photos, view a random photo, switch between list and preview mode")
                        .multilineTextAlignment(.leading)
                        .padding()
                } else {
                    Text("When you have some photos use the options on the bottom of the screen to filter photos or vidoes, sort the photos, view a random photo, switch between list and preview mode, select multiple for quick sharing")
                        .multilineTextAlignment(.leading)
                        .padding()
                }
                Image(systemName: "arrow.down")
            } else {
                switch viewModel.layoutType {
                case .list:
                    allPhotosList()
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
            footer()
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
    func allPhotosList() -> some View {
        List {
            ForEach(photoDataStore.photos) { photo in
                HStack {
                    PhotoDetailView(photo: photo)
                    .cornerRadius(8)
                    .border(.red, width: (viewModel.selectMultiple && viewModel.selectedIDs.contains(photo.id)) ? 4 : 0)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.viewType == .Taken {
                        if viewModel.selectMultiple {
                            if viewModel.selectedIDs.contains(photo.id) {
                                viewModel.selectedIDs.removeAll(where: { $0 == photo.id })
                            } else {
                                viewModel.selectedIDs.append(photo.id)
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
    
    @ViewBuilder
    func viewPhotosTypePicker() -> some View {
        Picker("", selection: $viewModel.viewType) {
            ForEach(AllPhotosViewType.allCases, id: \.self) {
                Text($0.description)
            }
        }
        .pickerStyle(.segmented)
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack {
            HStack {
                Button(action: {
                    showTakeImage.toggle()
                }, label: {
                    Image(systemName: "camera")
                        .font(.title2)
                })
                
                if viewModel.viewType == .Taken {
                    Divider()
                        .frame(height: 22)
                    
                    PhotosPicker(selection: $importImageItem, label: {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                    })
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack{
                Image("name")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 44)
                //                .foregroundStyle(.white)
            }
            
            HStack {
                Button(action: {
                    showKeys.toggle()
                }, label: {
                    Image(systemName: "key")
                        .font(.title2)
                })
                Divider()
                    .frame(height: 22)
                Button(action: {
                    showSettings.toggle()
                }, label: {
                    Image(systemName: "gear")
                        .font(.title2)
                })
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    @ViewBuilder
    func footer() -> some View {
        HStack {
            Menu(content: {
                Picker("Filter", selection: $viewModel.mediaType) {
                    ForEach(AllPhotosFilterType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }, label: {
                Image(systemName: "eye.slash")
                    .font(.title2)
            })
            
            Spacer()
            
            Menu(content: {
                Picker("", selection: $viewModel.sortBy, content: {
                    ForEach(AllPhotosSortType.allCases, id: \.self) {
                        Text($0.description)
                    }
                })
            }, label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title2)
            })
            
            
            Spacer()
            
            Button(action: {
                if let data = viewModel.viewRandom() {
                    photoToShow = data
                }
            }, label: {
                Image(systemName: "shuffle.circle")
                    .font(.title2)
            })
            
            Spacer()
            
            Button(action: {
                switch viewModel.layoutType {
                case .list:
                    viewModel.layoutType = .preview
                case .preview:
                    viewModel.layoutType = .list
                }
            }, label: {
                switch viewModel.layoutType {
                case .list:
                    Image(systemName: "photo")
                        .font(.title2)
                case .preview:
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title2)
                }
            })
            
            if viewModel.viewType == .Taken {
                Spacer()
                
                Button(action: {
                    viewModel.selectMultiple.toggle()
                }, label: {
                    if viewModel.selectMultiple {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .font(.title2)
                    } else {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                    }
                })
            }
        }
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
