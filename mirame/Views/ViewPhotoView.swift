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
                Text(photo.takenDate ?? Date(), style: .date)
                    .padding()
                
                ZStack {
                    if let isVideo = photo.isVideo, isVideo {
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
                        isFavorite = (try? DataBase.shared.favorite(photo: photo, isFavorite: !isFavorite)) ?? false
                    }, label: {
                        if isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                                .font(.title)
                        } else {
                            Image(systemName: "heart")
                                .font(.title)
                        }
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    if let localImage = photo.localImage, localImage {
                        Button(action: {
                            showShare.toggle()
                        }, label: {
                            Image(systemName: "shareplay")
                                .font(.title)
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            DataBase.shared.deleteLocally(photo: photo)
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
            DataBase.shared.incrementViewCount(photo: photo)
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
