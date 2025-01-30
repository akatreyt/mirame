//
//  ZLImageEditorViewController.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/4/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import UIKit
import SwiftUI
import ZLImageEditor

struct ZLImageEditorViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ZLEditImageViewController
    let image: UIImage
    let completion: ((UIImage?) -> Void)
    
    init (image: UIImage, completion: @escaping ((UIImage?) -> Void)) {
        self.image = image
        self.completion = completion
    }
    
    func makeUIViewController(context: Context) -> ZLEditImageViewController {
        ZLImageEditorConfiguration.default()
            .editImageTools([.draw, .clip, .textSticker, .mosaic, .filter, .adjust])
            .adjustTools([.brightness, .contrast, .saturation])
        
        let vc = ZLEditImageViewController(image: image, editModel: nil)
        vc.editFinishBlock = { ei, editImageModel in
            completion(ei)
        }
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ZLEditImageViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
