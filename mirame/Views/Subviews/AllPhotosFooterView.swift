//
//  AllPhotosFooterView.swift
//  mirame
//
//  Created by Trey Tartt on 1/30/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import SwiftUI

struct AllPhotosFooterView: View {
    @Binding var viewType: AllPhotosViewType
    @Binding var mediaType: AllPhotosFilterType
    @Binding var sortBy: AllPhotosSortType
    @Binding var layoutType: AllPhotosViewLayoutType
    @Binding var selectMultiple: Bool
    @Binding var isUnlocked: Bool
    
    let viewRandom: (() -> Void)
    
    var body: some View {
        HStack {
            Menu(content: {
                Picker("Filter", selection: $mediaType) {
                    ForEach(AllPhotosFilterType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }, label: {
                Image(systemName: "eye.slash")
                    .font(.title2)
            })
            
            Spacer()
            
            Menu(content: {
                Picker("", selection: $sortBy, content: {
                    ForEach(AllPhotosSortType.allCases, id: \.self) {
                        Text($0.description)
                    }
                })
            }, label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title2)
            })
            .disabled(!isUnlocked && viewType == .Saved )
            
            
            Spacer()
            
            Button(action: {
                viewRandom()
            }, label: {
                Image(systemName: "shuffle.circle")
                    .font(.title2)
            })
            .disabled(!isUnlocked && viewType == .Saved )
            
            Spacer()
            
            Button(action: {
                switch layoutType {
                case .list:
                    layoutType = .preview
                case .preview:
                    layoutType = .list
                }
            }, label: {
                switch layoutType {
                case .list:
                    Image(systemName: "photo")
                        .font(.title2)
                case .preview:
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title2)
                }
            })
            
            if viewType == .Taken {
                Spacer()
                
                Button(action: {
                    selectMultiple.toggle()
                }, label: {
                    if selectMultiple {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .font(.title2)
                    } else {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                    }
                })
            }
        }
    }
}

//#Preview {
//    AllPhotosFooterView()
//}
