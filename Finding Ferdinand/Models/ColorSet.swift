//
//  ColorSet.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/13/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(ColorSet)

class ColorSet: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var note: String
    @NSManaged var colors: [Color]
    @NSManaged var favourite: Bool
    @NSManaged var modifiedTime: Date

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(name: String, note: String, favourite: Bool, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entity(forEntityName: "ColorSet", in: context)!
        super.init(entity: entity, insertInto: context)
        
        let modified = Date()
        
        self.name = name
        self.note = note
        self.favourite = favourite
        self.modifiedTime = modified
    }
        
    var getPercent:[Int: Int] {
        var selections: [Int: Int]! = [Int: Int]()
        for color in colors {
            let index = ColorArray.index(of: color.name) as! Int
            selections[index] = color.percent as? Int
        }
        return selections        
    }

    var breakdown: String {
        var r = [String]()
        for color in colors {
            r.append("\(color.name) \(color.percent)%.")
        }
        
        return r.joined(separator: "  ")
    }
    
    var uiColor: UIColor {
        var mixture = [(UIColor, Int)]()
        for color in colors {
            if let uicolor = ColorDictionary[color.name] {
                mixture.append( (uicolor, Int(truncating: color.percent)) )
            }
        }
        return Tools.mixColors(mixture)
    }
}
