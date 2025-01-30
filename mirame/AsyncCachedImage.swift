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
                            image = await getImageData()
                        }
                    }
            }
        }
    }
    
    func getImageData() async -> Image? {
        guard let photo else { return nil }
        
        if let unlockedData = PhotoDataCache.shared.cache[photo.id] {
            if let uiImage = UIImage(data: unlockedData) {
                return Image(uiImage: uiImage)
            }
        }
        
        var image: UIImage?
        
        if photo.isVideo == 1 {
            image = UIImage(systemName: "play")
        }
        
        if photo.localImage == 1 {
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
            PhotoDataCache.shared.cache[photo.id] = image.resized(toWidth: 300)!.jpegData(compressionQuality: 1)
            return Image(uiImage: image)
        }
        return nil
    }
}
