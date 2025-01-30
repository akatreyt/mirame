//
//  AllPhotosFilterType.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/25/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//


enum AllPhotosFilterType: String, CaseIterable {
    case Photo = "Photo"
    case Video = "Video"
    case All = "All"
    
    var dbString: String {
        switch self {
        case .Photo: return "isVideo == 0"
        case .Video: return "isVideo == 1"
        case .All: return "(isVideo == 0 || isVideo == 1)"
        }
    }
}
