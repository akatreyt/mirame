//
//  NewPhotoView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/28/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//
import PhotosUI
import SwiftUI
import ZLImageEditor

struct NewPhotoView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State var status: NewPhotoViewStatus = .takePhoto
    @Environment(\.dismiss) var dismiss
    
    @State var alertConfig: AlertConfig? {
        didSet {
            showAlert = alertConfig != nil
        }
    }
    @State var showAlert: Bool = false
    
    enum NewPhotoViewStatus {
        case takePhoto
        case editPhoto(UIImage)
//        case editVideo
    }
    
    var body: some View {
        ZStack {
            switch status {
            case .takePhoto:
                SneakyCamViewControllerView(newImage: { image in
                    status = .editPhoto(image)
                }, newURL: { url in
                    Task {
                        do {
                            try await DataBase.shared.saveVideo(url)
                            dismiss()
                        } catch {
                            alertConfig = AlertConfig(
                                title: "Error saving",
                                message: "Error saving",
                                buttons: [])
                        }
                    }
                })
                
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .padding()
                                .foregroundStyle(.white)
                                .font(.title)
                        })
                        Spacer()
                    }
                    Spacer()
                }
                
            case .editPhoto(let image):
                ZLImageEditorViewController(image: image, completion: { newImage in
                    Task {
                        if let newImage {
                            do {
                                try await SaveDeleteContent.savePhoto(
                                    importedPhotoID: nil,
                                    image: image,
                                    keyDataSet: KeychainKeys.shared.personalKey,
                                    isLocal: true,
                                    allowedNumOfViews: -1,
                                    allowScreenShots: false,
                                    takenDate: Date(),
                                    disableFeedPreview: false
                                )
                            } catch {
                                
                            }
                        }
                    }
                })
            }
        }
        .background(.black)
    }
}
