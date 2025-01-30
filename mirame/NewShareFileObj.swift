//
//  NewPhotoObj.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/29/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//

import Foundation
import UIKit
import CoreTransferable

class NewShareFileObj: Codable, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .text)
    }
    
    var allowedNumOfViews : Int
    var screenShotsAllowed : Bool
    var photos : [Photo]
   
    init(allowedNumOfViews: Int, screenShotsAllowed: Bool, photos: [Photo]) {
        self.allowedNumOfViews = allowedNumOfViews
        self.screenShotsAllowed = screenShotsAllowed
        self.photos = photos
    }
}
