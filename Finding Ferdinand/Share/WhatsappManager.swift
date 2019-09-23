//
//  WhatsappManager.swift
//  Finding Ferdinand
//
//  Created by Ashwin Hamal on 8/5/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit

class WhatsappManager: NSObject, UIDocumentInteractionControllerDelegate {
    
    private let kWhatsappURL = "whatsapp://app"
    private let kUTI = "public.image" //"net.whatsapp.image"
    private let kAlertViewTitle = "Error"
    private let kAlertViewMessage = "Please install the Whatsapp application"
    
    var documentInteractionController = UIDocumentInteractionController()
    
    // singleton manager
    class var sharedManager: WhatsappManager {
        struct Singleton {
            static let instance = WhatsappManager()
        }
        return Singleton.instance
    }
    
    func postImageWithCaption(image: UIImage, caption: String, view: UIView) {
        // called to post image with caption to the instagram application
        
        let instagramURL = NSURL(string: kWhatsappURL)
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {            
            let imageLocalPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("public.jpeg")
            
            if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                do {
                    try imageData.write(to: imageLocalPath, options: .atomic)
                    self.documentInteractionController = UIDocumentInteractionController(url: imageLocalPath)
                    
                    self.documentInteractionController.delegate = self
                    self.documentInteractionController.uti = kUTI
                    
                    // adding caption for the image
                    self.documentInteractionController.annotation = ["WhatsappCaption": caption]
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
    
    
    @IBAction func whatsappShareLink(_ sender: AnyObject)
    {
        let originalString = "https://www.google.com"
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
        let url  = URL(string: "whatsapp://send?text=\(escapedString!)")
        
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    //https://stackoverflow.com/questions/45079931/sharing-live-photo-on-whatsapp-in-swift-3-using-uiactivityviewcontroller-not-wor
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        print("Application ----- \(String(describing: application))")
    }
    
}
