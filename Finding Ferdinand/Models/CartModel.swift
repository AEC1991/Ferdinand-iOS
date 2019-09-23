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

@objc(CartModel)

class CartModel: NSManagedObject {
    @NSManaged var colorSet: ColorSet
    @NSManaged var finish: String
    @NSManaged var size: String
    @NSManaged var quantity: Int
    @NSManaged var price: Float
    
    @NSManaged var modifiedTime: Date

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(colorSet: ColorSet, finish: String, size: String, quantity: Int, price: Float, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entity(forEntityName: "CartModel", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.colorSet = colorSet        
        self.finish = finish
        self.size = size
        self.quantity = quantity
        self.price = price
        
        self.modifiedTime = Date()
    }
}
