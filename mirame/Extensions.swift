//
//  UIImageExt.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/12/19.
//  Copyright © 2019 Trey Tartt. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIImage {
    func fixOrientation() -> UIImage {
        if (self.imageOrientation == .up)  {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension Date{
    func saveVideoDate()->String{
        let _dateFormatter = DateFormatter()
        _dateFormatter.dateFormat = "MMM_d_h_mm_ss_a"
        let _str =  _dateFormatter.string(from: self)
        return _str
    }
}

import AudioToolbox

extension SystemSoundID {
    static func playFileNamed(fileName: String, withExtenstion fileExtension: String)  {
        if let soundURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)  {
            var mySound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
            AudioServicesPlaySystemSound(mySound)
        }
    }
}

extension String{
    static func random(length : Int)->String{
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    static func symbolString(symbolName: String, withValue: String) -> NSMutableAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: symbolName)?.withTintColor(.sneakyTint)

        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: " \(withValue)"))
        return fullString
    }
}

extension UIColor{
    static let sneakyTint = UIColor(named: "SneakyTint")!
}

extension Notification.Name{
    static let SaveShareCommplete = Notification.Name("SaveShareComplete")
}

extension URL{
    static func createSneakyFileLocation() throws -> URL{
        let fileName = Constants.randomPhotoName
        
        guard var tmpFileLocation = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)?.absoluteString else {
            throw KeysProtocolError.unableToCreateURL
        }
        
        tmpFileLocation += "."+Constants.mirameExtension
        
        let tmpFileURL = URL(string: tmpFileLocation)!
        return tmpFileURL
    }
}

public extension View {
    func fullBackground(image: Image) -> some View {
        return background(
            image
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
    }
}

extension URL {
    static func getCompleteDocumentsURL(fileName:String)->URL{
        let completeURL = URL(fileURLWithPath: Constants.documentDirectoryPath.appendingPathComponent(fileName))
        return completeURL
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func compress(to kb: Int, allowedMargin: CGFloat = 0.2) -> Data {
        guard kb > 10 else { return Data() } // Prevents user from compressing below a limit (10kb in this case).
        let bytes = kb * 1024
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        var complete = false
        while(!complete) {
            guard let data = holderImage.jpegData(compressionQuality: 1.0) else { break }
            let ratio = data.count / bytes
            if data.count < Int(CGFloat(bytes) * (1 + allowedMargin)) {
                complete = true
                return data
            } else {
                let multiplier:CGFloat = CGFloat((ratio / 5) + 1)
                compression -= (step * multiplier)
            }
            guard let newImage = holderImage.resized(withPercentage: compression) else { break }
            holderImage = newImage
        }
        
        return Data()
    }
}

extension Image {
    @MainActor
    func getUIImage(newSize: CGSize) -> UIImage? {
        let image = resizable()
            .scaledToFit()
            .frame(width: newSize.width, height: newSize.height)
        return ImageRenderer(content: image).uiImage
    }
}
