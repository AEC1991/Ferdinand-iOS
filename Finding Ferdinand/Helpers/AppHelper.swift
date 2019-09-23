//
//  Commons.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/7/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


let YOUR_APP_STORE_ID = 545174222 //Change this one to your ID

class Tools {
    static func mixColors(_ mixture: [(UIColor, Int)]) -> UIColor {
        var cTotal = [0.0, 0.0, 0.0]
        var wTotal = 0.0
        
        for (color, percent) in mixture {
            var rgba = color.rgba()
            let p = Double(percent)
            cTotal[0] += rgba[0] * p
            cTotal[1] += rgba[1] * p
            cTotal[2] += rgba[2] * p
            wTotal = wTotal + p
        }
        for i in 0...2 {
            cTotal[i] = cTotal[i] / wTotal
        }
        
        return UIColor(
            red: CGFloat(cTotal[0]),
            green: CGFloat(cTotal[1]),
            blue: CGFloat(cTotal[2]),
            alpha: 1.0)
    }
    
    static func getNavImage() -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 180, height: 18))
        imageView.image = UIImage(named: "navigation")
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        return imageView
    }
    
    static func flashLabel(_ label: UIView) {
        UIView.animate(withDuration: 1.0, animations: {
            label.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, animations: {
                label.alpha = 0.0
            }, completion: { _ in
            })
        })
    }
    
    static func fadeIn(_ view: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 1.0
        }, completion: { _ in
        })
    }
    
    static func fadeOut(_ view: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 0.0
        }, completion: { _ in
        })
    }
    
    static func encode(_ str: String) -> String {
        return str.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    static func showAlert(_ vc: UIViewController, _ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func cropImage(_ image: UIImage, _ rect: CGRect) -> UIImage {
        let imageRef:CGImage = image.cgImage!.cropping(to: rect)!
        let croppedImage:UIImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
    
    
    static func setFirstOpen() {
        UserDefaults.standard.set(false, forKey: "firstOpen")
    }
    
    static func isFirstOpen() -> Bool {
        let value = UserDefaults.standard.object(forKey: "firstOpen")
        return value == nil
    }
    
    static func cartContent(_ set: ColorSet?, _ finish: String, _ productId: String, _ quantity: Int) -> String {
        
//        var dict : [String: Any?] = [:]
//        if let set = set {
//            dict["id"] = productId
//            dict["quantity"] = quantity
//
//            var dictProps : [String: Any?] = [:]
//            dictProps["Color Name"] = set.name
//
//            var i = 1
//            for color in set.colors {
//                dictProps["Color \(i)"] = "\(color.name) \(color.percent)%"
//                i = i + 1
//            }
//            dictProps["Finish"] = finish
//
//            dict["properties"] = dictProps
//        }
        
//        var json = JSON()
//        if let set = set {
//            json["id"].string = productId
//            json["quantity"].int = quantity
//
//            var jsonProps = JSON()
//            jsonProps["Color Name"].string = set.name
//            jsonProps["Finish"].string = finish
//
//            var i = 1
//            for color in set.colors {
//                jsonProps["Color \(i)"].string = "\(color.name) \(color.percent)%"
//                i = i + 1
//            }
//            json["properties"] = jsonProps
//        }
//
//        print("\(json)")
//        return json.rawString()!



        var textJson : String = "{\n"
        textJson += "\"id\": \"\(productId)\", \n"
        // textJson += "\"id\": \"33405203215\", \n" for dev site
        textJson += "\"quantity\": \(quantity), \n"

        if let set = set {
            var textProps : String = "{\n"
            textProps += "\"Color Name\": \"\(set.name)\", \n"
            textProps += "\"Finish\": \"\(finish)\""

            var i = 1
            for color in set.colors {
                textProps += ", \n"
                textProps += "\"Color \(i)\": \"\(color.name) \(color.percent)%\""

                i = i + 1
            }
            textProps += "\n}"

            textJson += "\"properties\": \(textProps)"
        }

        textJson += "\n}"

        print("\(textJson)")
        return textJson
    }
    
    static func getCartsCount(_ carts: [CartModel]) -> Int {
        var count : Int = 0
        for (_, element) in carts.enumerated() {
            count += element.quantity
        }
        return count
    }
    
    static func rateApp(_ vc: UIViewController) {
        if (PrefHelper.isRatedApp()) {
            return
        }
        
        let appID = kAppId
        //let urlStr = "itms-apps://itunes.apple.com/app/id\(appID)" // (Option 1) Open App Page
        let urlStr = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)" // (Option 2) Open App Review Tab
        
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }// Would contain the right link
        
        PrefHelper.setRateApp(true)
    }
    
}
