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
            return "Saved: Yesterday -> Today"
        case .DateSavedDesc:
            return "Saved: Today -> Yesterday"
        case .DateTakenAsc:
            return "Taken: Yesterday -> Today"
        case .DateTakenDesc:
            return "Taken: Today -> Yesterday"
        case .viewCountAsc:
            return "Viewed Less"
        case .viewCountDesc:
            return "Viewed More"
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
