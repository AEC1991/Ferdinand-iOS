//
//  Commons.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/7/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class WebService {    
    typealias RefreshCompletion = (_ succeeded: Bool, _ data: JSON) -> Void
    
    
    static func GetAllCarts(completion: @escaping RefreshCompletion) {
        let url = URL(string: "\(kWebServerURL)/cart.js")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(urlRequest)
            .authenticate(user: kUser, password: kPassword)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json)
                case .failure(let error):
                    print(error)
                    completion(false, JSON())
                }
        }
    }
    
    static func addToCart(_ json : String, completion: @escaping RefreshCompletion) {
        let url = URL(string: "\(kWebServerURL)/cart/add.js")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
//        let parameters = convertToDictionary(text: json)
        
//        do {
//            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters as Any, options: [])
//        } catch {
//            // No-op
//        }
        urlRequest.httpBody = json.data(using: .utf8)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(urlRequest)
            .authenticate(user: kUser, password: kPassword)
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json)
                case .failure(let error):
                    print(error)
                    completion(false, JSON())
                }
        }
    }
    
    static func updateQuantity(_ itemIdx: Int, _ quantity : Int, completion: @escaping RefreshCompletion) {
        let url = URL(string: "\(kWebServerURL)/cart/change.js?line=\(itemIdx)&quantity=\(quantity)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let parameters = [:] as [String: Any]?
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters as Any, options: [])
        } catch {
            // No-op
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(urlRequest)
            .authenticate(user: kUser, password: kPassword)
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json)
                case .failure(let error):
                    print(error)
                    completion(false, JSON())
                }
        }
    }
    
    static func updateProperties(_ itemIdx: Int, _ cart : CartModel, completion: @escaping RefreshCompletion) {
        
        let set = cart.colorSet
        
        var textProps : String = ""
        textProps += "properties[Color Name]=\(set.name)"
        textProps += "&properties[Finish]=\(cart.finish)"
        
        var i = 1
        for color in set.colors {
            textProps += "&properties[Color \(i)]=\(color.name) \(color.percent)%"

            i = i + 1
        }
        
        let urlString = textProps.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!        
        let url = URL(string: "\(kWebServerURL)/cart/change.js?line=\(itemIdx)&\(urlString)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let parameters = [:] as [String: Any]?
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters as Any, options: [])
        } catch {
            // No-op
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(urlRequest)
            .authenticate(user: kUser, password: kPassword)
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json)
                case .failure(let error):
                    print(error)
                    completion(false, JSON())
                }
        }
    }
    
    
    static func login(_ email: String, _ password : String, completion: @escaping RefreshCompletion) {
        let url = URL(string: "\(kWebServerURL)/api/graphql")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let parameters = "mutation {customerAccessTokenCreate (input:{email:\"\(email)\",password:\"\(password)\"}){customerAccessToken{accessToken}}}" as String
        
        urlRequest.httpBody = parameters.data(using: .utf8)
        
        urlRequest.setValue(kStorefrontAccessToken, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")
        urlRequest.setValue("application/graphql", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(urlRequest)
            .authenticate(user: kUser, password: kPassword)
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json)
                case .failure(let error):
                    print(error)
                    completion(false, JSON())
                }
        }
    }
    
    
    static func signup(_ email: String, _ password: String, _ firstName: String, _ lastName: String, completion: @escaping RefreshCompletion) {
        let url = URL(string: "\(kWebServerURL)/api/graphql")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let parameters = "mutation {customerCreate (input:{email:\"\(email)\",password:\"\(password)\",firstName:\"\(firstName)\",lastName:\"\(lastName)\"}){customer{id}}}" as String
        
        urlRequest.httpBody = parameters.data(using: .utf8)
        
        urlRequest.setValue(kStorefrontAccessToken, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")
        urlRequest.setValue("application/graphql", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(urlRequest)
            .authenticate(user: kUser, password: kPassword)
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json)
                case .failure(let error):
                    print(error)
                    completion(false, JSON())
                }
        }
    }
    
    
    static func forgotPassword(_ email: String, completion: @escaping RefreshCompletion) {
        let url = URL(string: "\(kWebServerURL)/api/graphql")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let parameters = "mutation {customerRecover (email:\"\(email)\"){userErrors{field}}}" as String
        
        urlRequest.httpBody = parameters.data(using: .utf8)
        
        urlRequest.setValue(kStorefrontAccessToken, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")
        urlRequest.setValue("application/graphql", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(urlRequest)
            .authenticate(user: kUser, password: kPassword)
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json)
                case .failure(let error):
                    print(error)
                    completion(false, JSON())
                }
        }
    }
    
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
