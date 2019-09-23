//
//  Color.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/13/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Color)

class Color: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var percent: NSNumber
    @NSManaged var colorSet: ColorSet

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(name: String, percent: Int, colorSet: ColorSet, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entity(forEntityName: "Color", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.name = name
        self.colorSet = colorSet
        self.percent = NSNumber(value: percent as Int)
    }
}
