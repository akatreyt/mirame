//
//  Constants.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/6/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import Foundation

struct Constants {
    static let mirameExtension = "mirame"
    
    static var randomPhotoName : String{
        get{
            let allNames = ["Note Share", "Reminder Share", "Shared", "Check this out"]
            return allNames.randomElement() ?? String.random(length: 5)
        }
    }
    
    static var randomTokenName : String{
        get{
            let allNames = ["Lets share", "Wanna see", "Take a peek"]
            return allNames.randomElement() ?? String.random(length: 5)
        }
    }
    
    static var documentDirectoryPath: NSString {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        return documentDirectoryPath
    }
}

enum UIAlertTypes : String, Error{
    case couldNotDeactivateKey
    case couldNotDecryptUsingKey
    case couldNotLoadPasedFile
    case uknownFileExtension
    
    case errorDeletingAllPhotosForKey
    case noViewsLeft = "You have reached your max number of views"
    case errorSharing = "Error Sharing photo"
    case errorRecording = "Error recording video"
    case errorDeleting = "Error deleting photo"
    case errorDecoding = "Unable to decode image, try a different key?"
    case errorSaving = "Unable to save image, try a different key?"
    case tookScreenShotDelete = "Should not have done that!!!!"
    
    case savedPhoto
    case savedVideo
    case savedToken
    case savedDBKey
    case savedPersonalKey
}
