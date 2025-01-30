//
//  SneakyCamViewControllerView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/28/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//
import SneakyCamPackage
import SwiftUI

struct SneakyCamViewControllerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SneakyCamViewController
    
    let newImage: ((UIImage) -> Void)
    let newURL: ((URL) -> Void)
    
    init(newImage: @escaping (UIImage) -> Void, newURL: @escaping (URL) -> Void) {
        self.newImage = newImage
        self.newURL = newURL
    }
    
    func makeUIViewController(context: Context) -> SneakyCamViewController {
        let vc = SneakyCamViewController.instantiate()
        vc.imageCompletion = { image in
            newImage(image)
        }
        vc.videoCompletion = {  url in
            newURL(url)
        }
        vc.setDocumentFiles(docFiles: DocumentsFetcher.readFiles())
//        vc.presentationController?.delegate = self
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SneakyCamViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
