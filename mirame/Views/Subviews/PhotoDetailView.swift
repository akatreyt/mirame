//
//  PhotoDetailView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/25/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//
import SwiftUI

enum PhotoType {
    case image
    case video
}

struct PhotoDetailView: View, Identifiable {
    var id: ObjectIdentifier {
        photo.id
    }
    
    var photo: Photo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "calendar")
                Text("\(photo.takenDate ?? Date(), style: .date)")
            }
            
            HStack {
                if let isVideo = photo.isVideo, isVideo {
                    Image(systemName: "video")
                } else {
                    Image(systemName: "photo")
                }
                
                Spacer()
                Image(systemName: "eye")
                Text("\(photo.numberOfViews ?? 0)")
                
                Spacer()
                Image(systemName: "lock")
                Text(photo.keyName ?? "NA")
            }
            .padding(.vertical)
            
            HStack {
                Image(systemName: "envelope.open.fill")
                Text("\(photo.lastViewDate ?? Date(), style: .date)")
            }
        }
        .padding()
    }
}

//#Preview {
//    PhotoDetailView(
//        photoID: "1",
//        dateTaken: Date(),
//        lastDateOpened: Date(),
//        viewCount: 4,
//        keyName: "test",
//        photoType: .image)
//}
