//
//  UIActivityViewController.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/28/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//
import SwiftUI

struct UIActivityViewControllerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIActivityViewController
    let url: URL
    
    init (url: URL) {
        self.url = url
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let itemSource = AirDropOnlyActivityItemSource(item: url)
        let activityVc = UIActivityViewController(activityItems: [itemSource], applicationActivities: nil)
        return activityVc
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
