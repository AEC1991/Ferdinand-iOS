//
//  PrefHelper.swift
//  Ferdinand
//
//  Created by Alex on 7/5/18.
//  Copyright © 2018 BrightGo Inc. All rights reserved.
//

import Foundation
import UIKit


class PrefHelper {
    
    static let kFirstInApp = "notFirstInApp"
    static let kUserEmail = "UserEmail"
    static let kRateApp = "rateApp"
    
    static func setUserEmail(_ email: String) {
        UserDefaults.standard.set(email, forKey: kUserEmail)
    }
    
    static func getUserEmail() -> String? {
        let value = UserDefaults.standard.object(forKey: kUserEmail)
        if (value == nil) {
            return nil
        }
        
        return value as? String
    }
    
    static func removeUserEmail() {
        UserDefaults.standard.removeObject(forKey: kUserEmail)
    }
    

    static func setFirstOpen(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: kFirstInApp)
    }

    static func isFirstOpen() -> Bool {
        return UserDefaults.standard.bool(forKey: kFirstInApp)
    }
    
    
    
    static func setRateApp(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: kRateApp)
    }

    static func isRatedApp() -> Bool {
        return UserDefaults.standard.bool(forKey: kRateApp)
    }
}
