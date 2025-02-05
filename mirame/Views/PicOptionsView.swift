//
//  PicOptionsView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/29/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//

import SwiftUI
import UIKit
import AVFoundation
import AVKit
import SneakySync

struct EditablePhoto: Identifiable, Equatable {
    let id: UUID
    let image: UIImage?
    var editableImage: UIImage?
    var videoData: Data?
}

struct PicOptionsView: View {
    let photos: [Photo]
    @State var allKeys = [KeyDataSet]()
    @State var numberOfViews: Int = 1
    @State var allowScreenshots: Bool = false
    @State var newShareFileObjURL: URL?
    @State var pickedKey: KeyDataSet?
    @State var photoToEdit: EditablePhoto?
    @State private var shareURL: String?
    @State private var editablePhotos = [EditablePhoto]()
    @State private var limitedNumberOfViews = false
    @State private var disableFeedPreview = false
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: 30) {
                    ForEach(editablePhotos) { photo in
                        if let editableImage = photo.editableImage {
                            Image(uiImage: editableImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .onTapGesture {
                                    photoToEdit = photo
                                }
                        } else {
                            Image(systemName: "play.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                        }
                    }
                }
            }
            .padding()
            
            Text("Tap photo to edit")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.top)
            
            List {
                Section {
                    
                }
                
                Section {
                    Toggle("Limit number of views", isOn: $limitedNumberOfViews)
                    
                    if limitedNumberOfViews {
                        Stepper("Number of Views: \(numberOfViews)", value: $numberOfViews, in: 1...100)
                    }
                }
                
                Section {
                    Toggle("Allow screenshots", isOn: $allowScreenshots)
                } header: {
                    Text("Allow screenshots desc")
                }
                
                Section {
                    Toggle("Disable preview on feed", isOn: $disableFeedPreview)
                } header: {
                    Text("Disable preview on feed")
                }
                
                Section {
                    ForEach(allKeys, id: \.id) { key in
                        HStack {
                            if pickedKey?.id == key.id {
                                Image(systemName: "checkmark")
                            }
                            if let name = key.name {
                                Text(name)
                            } else {
                                Text("NA")
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            pickedKey = key
                        }
                    }
                } header: {
                    Text("Pick a key to share with")
                }
            }
            .padding(.top, -8)
            
            Button(action: {
                do {
                    var updatedPhotos = [PhotoShareObject]()
                    for photo in photos {
                        var tempPhoto = photo.shareObject
                        if let editedData = editablePhotos.first(where: {
                            $0.id == photo.id
                        }) {
                            if let videoData = editedData.videoData {
                                tempPhoto.imageData = videoData
                            } else {
                                tempPhoto.imageData = editedData.editableImage?.pngData()
                            }
                        }
                        tempPhoto.allowedNumberOfViews = limitedNumberOfViews ? numberOfViews : -1
                        tempPhoto.screenShotsAllowed = allowScreenshots
                        tempPhoto.disableFeedPreview = disableFeedPreview
                        
                        updatedPhotos.append(tempPhoto)
                    }
                    if let pickedKey = pickedKey {
                        let tmpFileLocation = try ImportExport.encode(
                            photos: updatedPhotos,
                            keyDataSet: pickedKey)
                        shareURL = tmpFileLocation.absoluteString
                    }
                } catch {
                    
                }
            }, label: {
                Image(systemName: "shareplay")
                    .font(.title)
            })
            .disabled(pickedKey == nil)
            .padding()
        }
        .sheet(item: $shareURL) { url in
            ActivityView(url: URL(string: url)!)
        }
        .fullScreenCover(item: $photoToEdit) { photo in
            if let editableImage = photo.editableImage {
                ZLImageEditorViewController(image: editableImage,
                                            completion: { newImage in
                    if let newImage {
                        if let idx = editablePhotos.firstIndex(of: photo) {
                            editablePhotos[idx].editableImage = newImage
                        }
                    }
                })
            }
        }
        .onAppear() {
            allKeys = KeychainKeys.shared.allKeys
            
            photos.forEach({ photo in
                if let isVideo = photo.isVideo, isVideo {
                    if let url = photo.showVideo(key: KeychainKeys.shared.personalKey),
                       let decryptedData = try? Data(contentsOf: url) {
                        let editablePhoto = EditablePhoto(id: photo.id ?? UUID(), image: nil, editableImage: nil, videoData: decryptedData)
                        editablePhotos.append(editablePhoto)
                    }
                } else {
                    if let decryptedImage = photo.showImage(key: KeychainKeys.shared.personalKey) {
                        let editablePhoto = EditablePhoto(id: photo.photoID, image: decryptedImage, editableImage: decryptedImage)
                        editablePhotos.append(editablePhoto)
                    }
                }
            })
        }
    }
}

//#Preview {
//    var somePhoto: Photo {
//        var photo = Photo()
//        photo.iamgeData = UIImage(systemName: "square.and.arrow.up")?.jpegData(compressionQuality: 1.0)
//        return photo
//    }
//    
//    var somePhoto2: Photo {
//        var photo = Photo()
//        photo.iamgeData = UIImage(systemName: "sharedwithyou.circle")?.jpegData(compressionQuality: 1.0)
//        return photo
//    }
//    
//    var somePhoto3: Photo {
//        var photo = Photo()
//        photo.iamgeData = UIImage(systemName: "shareplay")?.jpegData(compressionQuality: 1.0)
//        return photo
//    }
//    
//    PicOptionsView(photos: [
//        somePhoto, somePhoto2, somePhoto3
//    ])
//}


struct ActivityView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    
    let url: URL
    
    func makeUIViewController(context: UIActivityViewController) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
