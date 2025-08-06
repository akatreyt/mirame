//
//  AsyncCachedImage.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/10/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import SwiftUI

@MainActor
struct AsyncCachedImage<ImageView: View, PlaceholderView: View>: View {
    // Input dependencies
    var photo: Photo?
    @ViewBuilder var content: (Image) -> ImageView
    @ViewBuilder var placeholder: () -> PlaceholderView
    
    // Downloaded image
    @State var image: Image? = nil
    
    init(photo: Photo?,
        @ViewBuilder content: @escaping (Image) -> ImageView,
        @ViewBuilder placeholder: @escaping () -> PlaceholderView) {
        self.image = nil
        self.photo = photo
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        VStack {
            if let uiImage = image {
                content(uiImage)
            } else {
                placeholder()
                    .onAppear {
                        Task {
                            if let results = await getImageData(),
                               results.1 == photo?.photoID {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    image = results.0
                                }
                            }
                        }
                    }
            }
        }
        .onDisappear(perform: {
            image = nil
        })
    }
    
    func getImageData() async -> (Image?, UUID)? {
        guard let photo else { return nil }
        
        if let unlockedData = PhotoDataCache.shared.cache[photo.photoID.uuidString] {
            if let uiImage = UIImage(data: unlockedData) {
                return (Image(uiImage: uiImage), photo.photoID)
            }
        }
        
        var image: UIImage?
        
        if let isVideo = photo.isVideo, isVideo {
            image = UIImage(systemName: "play")
        }
        
        if let localImage = photo.localImage, localImage {
            let key = KeychainKeys.shared.personalKey
            if let _image = photo.showImage(key: key) {
                image = _image
            }
        } else {
            if let keyUUID = photo.privateKeyUUID,
               let key = KeychainKeys.shared.getKeyWith(id: keyUUID),
               let _image = photo.showImage(key: key) {
                image = _image
            }
        }
        
        if let image {
            PhotoDataCache.shared.cache[photo.photoID.uuidString] = image.resized(toWidth: 300)!.jpegData(compressionQuality: 1)
            return (Image(uiImage: image), photo.photoID)
        }
        return nil
    }
}
