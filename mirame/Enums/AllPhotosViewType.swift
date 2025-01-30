//
//  AllPhotosViewType.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/25/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//


enum AllPhotosViewType: Int, CaseIterable {
    var description: String {
        switch self {
        case .Taken: return "Taken"
        case .Saved: return "Saved"
        case .favorites: return "Favorites"
        }
    }
    
    var dbString: String {
        switch self {
        case .Taken:
            "localImage == 1"
        case .Saved:
            "localImage == 0"
        case .favorites:
            "isFavorite == 1"
        }
    }
    
    case Taken
    case Saved
    case favorites
}


