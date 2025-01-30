//
//  AirDropOnlyActivityItemSource.swift
//  mirame-ios
//
//  Created by Trey Tartt on 11/2/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import Foundation
import UIKit

class AirDropOnlyActivityItemSource: NSObject, UIActivityItemSource {
    ///The item you want to send via AirDrop.
    let item: Any
    
    init(item: Any)  {
        self.item = item
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        //using NSURL here, since URL with an empty string would crash
        return NSURL(string: "")!
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return item
    }
}
