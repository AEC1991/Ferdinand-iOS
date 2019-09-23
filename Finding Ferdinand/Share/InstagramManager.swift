//
//  InstagramManager.swift
//  Finding Ferdinand
//
//  Created by Ashwin Hamal on 8/5/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit

class InstagramManager: NSObject, UIDocumentInteractionControllerDelegate {
    
    private let kInstagramURL = "instagram://app"
    private let kUTI = "com.instagram.exclusivegram"
    private let kfileNameExtension = "instagram.igo"
    private let kAlertViewTitle = "Error"
    private let kAlertViewMessage = "Please install the Instagram application"
    
    var documentInteractionController = UIDocumentInteractionController()
    
    // singleton manager
    class var sharedManager: InstagramManager {
        struct Singleton {
            static let instance = InstagramManager()
        }
        return Singleton.instance
    }
    
    func postImageWithCaption(image: UIImage, caption: String, view: UIView) {
        // called to post image with caption to the instagram application
        
        let instagramURL = NSURL(string: kInstagramURL)
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {            
            let imageLocalPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("public.jpeg")
            
            if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                do {
                    try imageData.write(to: imageLocalPath, options: .atomic)
                    self.documentInteractionController = UIDocumentInteractionController(url: imageLocalPath)
                    
                    self.documentInteractionController.delegate = self
                    self.documentInteractionController.uti = kUTI
                    
                    // adding caption for the image
                    self.documentInteractionController.annotation = ["InstagramCaption": caption]
                    self.documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: view, animated: true)
                    
                } catch {
                    print(error)
                }
            }
        } else {            
            // alert displayed when the instagram application is not available in the device
            UIAlertView(title: kAlertViewTitle, message: kAlertViewMessage, delegate:nil, cancelButtonTitle:"Ok").show()
        }
    }
}
