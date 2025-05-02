//
//  PhotoDetailViewPreview.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/5/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import SwiftUI

class PhotoDataCache {
    static let shared = PhotoDataCache()
    var cache: [String: Data] = [:]
}

struct PhotoDetailViewPreview: View {
    @AppStorage("alwaysHideMedia")  private var alwaysHideMedia = false

    var photo: Photo
    var isLocked: Bool
    
    var body: some View {
        ZStack {
            if let isVideo = photo.isVideo, isVideo {
                Color(uiColor: .systemGroupedBackground)
                
                VStack {
                    Spacer()
                    Image(systemName: "video")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .frame(height: 300)
                        .contentShape(Rectangle())
                    Spacer()
                }
            } else {
                AsyncCachedImage(photo: photo,
                                 content: { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0)
                        .cornerRadius(8)
                        .background(photo.disableFeedPreview ?? false ? .ultraThinMaterial : .regular)
                        .frame(height: 300)
                        .scaleEffect(1.5)
                        .clipped()
                        .contentShape(Rectangle())
                        .overlay(content: {
                            if isLocked {
                                ZStack {
                                    Image(systemName: "lock")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.secondary)
                                        .padding(16)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.ultraThinMaterial)
                            } else {
                                if let disableFeedPreview = photo.disableFeedPreview, disableFeedPreview || alwaysHideMedia {
                                    ZStack {
                                        Image(systemName: "eye.slash")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(.secondary)
                                            .padding(16)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.ultraThinMaterial)
                                }
                            }
                        })
                }, placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.bottom, 50)
                })
            }
            
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "calendar")
                    Text("\(photo.takenDate ?? Date(), style: .date)")
                    Spacer()
                    Text("\(photo.numberOfViews ?? 0)")
                    Image(systemName: "eye")
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .overlay (
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(UIColor.systemBackground), lineWidth: 3)
        )
    }
}

//#Preview {
//    PhotoDetailViewPreview(
//        photoID: "1",
//        dateTaken: Date(),
//        lastDateOpened: Date(),
//        viewCount: 4,
//        photoType: .image,
//        imageData: nil)
//}
