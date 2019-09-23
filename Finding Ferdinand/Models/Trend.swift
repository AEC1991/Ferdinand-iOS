//
//  Trend.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/14/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit

class Trend {
    var colors: [String: Int]
    var description: String
    var images: [String]
    var name: String
    
    init(name: String, colors: [String: Int], description: String, images: [String]) {
        self.colors = colors
        self.description = description
        self.images = images
        self.name = name
    }
    
    func fetchImage(_ cb: @escaping (_ image: UIImage?, _ error: NSError?) ->  Void) -> URLSessionTask? {
        let url = self.images[0]
        return TrendClient.fetchImage(url, cb: cb)
    }

    deinit {
        for i in images {
            ImageCache.sharedInstance().storeImage(nil, withIdentifier: i)
        }
    }

    var breakdown : String {
        var r = [String]()
        for (colorName, percent) in colors {
            r.append("\(colorName) \(percent)% . ")
        }
        if r.count > 2 {
            r.insert("\n", at: 2)
        }
        return r.joined(separator: "")
    }

    var uiColor: UIColor {
        var mix = [(UIColor, Int)]()
        for (colorName, percent) in colors {
            if let color = ColorDictionary[colorName] {
                mix.append((color, percent))
            } else {
                print("Warning: Color not found")
            }
        }
        return Tools.mixColors(mix)
    }
}

class TrendClient {
    static func fetchImage(_ url: String, cb: @escaping (_ image: UIImage?, _ error: NSError?) ->  Void) -> URLSessionTask? {
        if let image =  ImageCache.sharedInstance().imageWithIdentifier(url) {
            print("Via Cache!")
            cb(image, nil)
            return nil
        }
        
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, downloadError in
            DispatchQueue.main.async {
                if let error = downloadError {
                    return cb(nil, error as NSError?)
                }
                if let data = data {
                    let image = UIImage(data: data)
                    ImageCache.sharedInstance().storeImage(image, withIdentifier: url)
                    return cb(image, downloadError as NSError?)
                }
            }
        }) 
        task.resume()
        return task
    }

    
    static func loadTrends(_ cb: @escaping (NSError?, [Trend]?)->()) {
        let request = URLRequest(url: URL(string: TrendsURL)!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if error != nil { return cb(error as NSError?, nil) }
            do {
                let obj = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                if let dictList = obj as? [NSDictionary] {
                    DispatchQueue.main.async {
                        var list = [Trend]()
                        for dict in dictList {
                            if let t = TrendClient.fromDict(dict) {
                                list.append(t)
                            }
                        }
                        return cb(nil, list)
                    }
                    return
                }
            } catch { }
            cb( NSError(domain: "Could not load data", code: 1, userInfo: nil), nil)
        }) 
        task.resume()
    }
    
    static func fromDict(_ dict: NSDictionary) -> Trend? {
        if let
            name = dict["name"] as? String,
            let description = dict["description"] as? String,
            let images = dict["images"] as? [String],
            let colors = dict["colors"] as? [[String: AnyObject]] {
            var cs = [String: Int]()
            for c in colors {
                if let cn = c["name"] as? String,
                    let cp = c["percent"] as? Int {
                    cs[cn] = cp
                }
            }
            return Trend(name: name, colors: cs, description: description, images: images)
        }
        return nil
    }
}
