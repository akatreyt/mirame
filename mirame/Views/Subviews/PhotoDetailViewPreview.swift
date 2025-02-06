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
                    Spacer()
                }
                .frame(height: 300)
            } else {
                AsyncCachedImage(photo: photo,
                                 content: { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0)
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(8)
                        .padding(-20)
                        .background(photo.disableFeedPreview ?? false ? .ultraThinMaterial : .regular)
                }, placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(height: 300)
                        .padding(.bottom, 50)
                })
                .overlay(content: {
                    if isLocked {
                        Image(systemName: "lock")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 0)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(8)
                            .padding(90)
                            .background(.ultraThinMaterial)
                            .foregroundStyle(.secondary)
                    } else {
                        if let disableFeedPreview = photo.disableFeedPreview, disableFeedPreview {
                            Image(systemName: "eye.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(minWidth: 0)
                                .frame(height: 300)
                                .clipped()
                                .cornerRadius(8)
                                .padding(90)
                                .background(.ultraThinMaterial)
                                .foregroundStyle(.secondary)
                        }
                    }
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
