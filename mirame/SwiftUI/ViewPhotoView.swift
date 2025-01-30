//
//  ViewPhotoView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/25/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//

import SwiftUI
import AVFoundation
import AVKit
import ScreenShield
import SneakySync

struct ViewPhotoView: View {
    let photo: Photo
    let keyDataSet: KeyDataSet?
    
    @State var showShare: Bool = false
    @State var isFavorite: Bool = false
    
    @State var alertconfig: AlertConfig? {
        didSet {
            hasAlert = true
        }
    }
    @State var hasAlert: Bool = false
    @Environment(\.dismiss) var dismiss
    
    @State var isRecordingScreen = false
    
    lazy var dateFormatter : DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            if let key = keyDataSet {
                if let date = photo.takenDate {
                    Text(date, style: .date)
                        .padding()
                }
                
                ZStack {
                    if photo.isVideo == 1 {
                        if let videoURL = photo.showVideo(key: key) {
                            VideoPlayer(player: AVPlayer(url: videoURL))
                                .protectScreenshot()
                        }
                    } else {
                        if let image = photo.showImage(key: key) {
                            ZoomableScrollView {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .protectScreenshot() 
                            }
                        }
                    }
                }
                
                HStack {
                    Button(action: {
                        isFavorite = (try? photo.favorite(isFavorite: !isFavorite)) ?? false
                    }, label: {
                        isFavorite ? Image(systemName: "heart.fill")
                            .font(.title) : Image(systemName: "heart").font(.title)
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    if photo.localImage == 1 {
                        Button(action: {
                            showShare.toggle()
                        }, label: {
                            Image(systemName: "shareplay")
                                .font(.title)
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            try? DataBase.deleteLocally(photo: photo)
                            dismiss()
                        }, label: {
                            Image(systemName: "trash")
                                .font(.title)
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            }
        }
        .sheet(isPresented: $showShare) { } content: {
            PicOptionsView(photos: [photo])
        }
        .onAppear() {
            isFavorite = photo.isFavorite ?? false
            try? photo.incrementViewCount()
            ScreenShield.shared.protectFromScreenRecording()
        }
        .alert(
            alertconfig?.title ?? "",
            isPresented: $hasAlert,
            actions: {
                
            }, message: {
                if let message = alertconfig?.message {
                    Text(message)
                }
            })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            print("Screenshot taken")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
            isRecordingScreen.toggle()
            print(isRecordingScreen ? "Started recording screen" : "Stopped recording screen")
        }
    }
}

//#Preview {
//    ViewPhotoView()
//}
