//
//  AllPhotosSortType.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/25/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//


enum AllPhotosSortType: String, CaseIterable, CustomStringConvertible {
    var description: String{
        switch self {
        case .DateSavedAsc:
            return "Date Saved - Latest"
        case .DateSavedDesc:
            return "Date Saved - Oldest"
        case .DateTakenAsc:
            return "Date Taken - Oldest"
        case .DateTakenDesc:
            return "Date Taken - Latest"
        case .viewCountAsc:
            return "View Count - Less"
        case .viewCountDesc:
            return "View Count - More"
        }
    }
    
    var dbString: String {
        switch self {
        case .DateSavedAsc:
            ""
        case .DateSavedDesc:
            ""
        case .DateTakenAsc:
            ""
        case .DateTakenDesc:
            ""
        case .viewCountAsc:
            ""
        case .viewCountDesc:
            ""
        }
    }
    
    case DateSavedAsc
    case DateSavedDesc
    
    case DateTakenAsc
    case DateTakenDesc
    
    case viewCountAsc
    case viewCountDesc
}
