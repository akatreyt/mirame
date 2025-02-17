//
//  PreviewViewController.swift
//  MirameHGPreview
//
//  Created by Trey Tartt on 2/17/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import UIKit
import QuickLook

class PreviewViewController: UIViewController, QLPreviewingController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void)  {
        label.text = "Tap share below to open in mírame"
        handler(nil)
    }

}
