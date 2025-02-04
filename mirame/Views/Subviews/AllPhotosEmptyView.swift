//
//  AllPhotosEmptyView.swift
//  mirame
//
//  Created by Trey Tartt on 1/30/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import SwiftUI

struct AllPhotosEmptyView: View {
    @Binding var viewType: AllPhotosViewType
    
    var body: some View {
        VStack {
            if viewType == .Saved {
                Text("No photos found.")
                    .padding()
                
                Text("Find someone to share photos with and share a key by tapping the \(Image(systemName: "key")), located on the top right")
                    .multilineTextAlignment(.leading)
                    .padding()
            }
            if viewType == .Taken {
                Text("You havent taken any photos yet")
                    .padding()
                
                Text("Tap \(Image(systemName: "camera")), located on the top left, to take a few")
                    .multilineTextAlignment(.leading)
                    .padding()
            }
            if viewType == .favorites {
                Text("No favorites")
                    .padding()
                
                Text("Once you favorite some photos, by tapping on the \(Image(systemName: "heart")) when viewing the photo, they will be located here for quick access")
                    .multilineTextAlignment(.leading)
                    .padding()
            }
            Spacer()
            if viewType == .Saved {
                Text("When you have some photos use the options on the bottom of the screen to filter photos or vidoes, sort the photos, view a random photo, switch between list and preview mode")
                    .multilineTextAlignment(.leading)
                    .padding()
            } else {
                Text("When you have some photos use the options on the bottom of the screen to filter photos or vidoes, sort the photos, view a random photo, switch between list and preview mode, select multiple for quick sharing")
                    .multilineTextAlignment(.leading)
                    .padding()
            }
            Image(systemName: "arrow.down")
        }
    }
}
//
//#Preview {
//    AllPhotosEmptyView()
//}
