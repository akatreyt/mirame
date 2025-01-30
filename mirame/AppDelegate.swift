//
//  AppDelegate.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/1/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    lazy var loadSharedQueue : OperationQueue = {
        let queue = OperationQueue()
        queue.isSuspended = true
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var verified:Bool = false {
        didSet{
            if loadSharedQueue.operations.count > 0 {
                DispatchQueue.main.async {
                    self.loadSharedQueue.isSuspended = false
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        gotFile(atURL: url)
        return true
    }
    
    open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        gotFile(atURL: url)
        return true
    }
    
    private func gotFile(atURL url: URL)  {
#warning("add delete operation back in")
        //        loadSharedQueue.addOperation {
        //            self.deleteTmpData()
        //        }
        if !verified {
            loadSharedQueue.addOperation {
                self.parseDataAndSave(url: url)
            }
        }else{
            self.parseDataAndSave(url: url)
        }
    }
    
    private func parseDataAndSave(url : URL)  {
//        DispatchQueue.main.async {
//            if let vcs = self.window?.rootViewController{
//                ShareFileAction.parsefile(url: url, onViewController: vcs, showPic: true)
//            }
//        }
    }
    
    private func deleteTmpData(){
//        ShareFileAction.deleteFile()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)  {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        verified = false
        self.loadSharedQueue.isSuspended = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)  {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        #if targetEnvironment(simulator)
            verified = true
        #else
        if !verified {
            let storyboard = UIStoryboard(name: "FaceIDViewController", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "FaceIDViewController")
            controller.modalTransitionStyle = .coverVertical
            self.window!.rootViewController?.present(controller, animated: true, completion: nil)
        }
        #endif
    }
}

