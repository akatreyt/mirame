//
//  AllPhotosHeaderView.swift
//  mirame
//
//  Created by Trey Tartt on 1/30/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import SwiftUI
import PhotosUI

struct AllPhotosHeaderView: View {
    @Binding var viewType: AllPhotosViewType
    @Binding var importImageItem: [PhotosPickerItem]
    @Binding var showKeys: Bool
    @Binding var showSettings: Bool
    @Binding var showTakeImage: Bool
    
    var body: some View {
        HStack {
            HStack {
                Button(action: {
                    showTakeImage.toggle()
                }, label: {
                    Image(systemName: "camera")
                        .font(.title2)
                })
                
                if viewType == .Taken {
                    Divider()
                        .frame(height: 22)
                    
                    PhotosPicker(selection: $importImageItem, label: {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                    })
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack{
                Image("name")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 44)
            }
            
            HStack {
                Button(action: {
                    showKeys.toggle()
                }, label: {
                    Image(systemName: "key")
                        .font(.title2)
                })
                Divider()
                    .frame(height: 22)
                Button(action: {
                    showSettings.toggle()
                }, label: {
                    Image(systemName: "gear")
                        .font(.title2)
                })
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

//#Preview {
//    AllPhotosHeaderView()
//}
