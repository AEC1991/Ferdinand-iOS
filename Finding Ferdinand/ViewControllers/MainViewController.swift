//
//  MainViewController.swift
//  Ferdinand
//
//  Created by alex on 3/21/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MainViewController: UITabBarController, NSFetchedResultsControllerDelegate {
    
    static var _instance : MainViewController? = nil
    static var Instance: MainViewController = {
        return _instance!
    }()
    
    static var colorSets = [ColorSet]()
    static var carts = [CartModel]()
    var indicator = UIActivityIndicatorView()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedColorSetResultsController: NSFetchedResultsController<ColorSet> = {
        let timeSort = NSSortDescriptor(key: "modifiedTime", ascending: false)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ColorSet")
        fetchRequest.sortDescriptors = [timeSort]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return fetchedResultsController as! NSFetchedResultsController<ColorSet>
    } ()
    
    lazy var fetchedCartResultsController: NSFetchedResultsController<CartModel> = {
        let timeSort = NSSortDescriptor(key: "modifiedTime", ascending: false)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CartModel")
        fetchRequest.sortDescriptors = [timeSort]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return fetchedResultsController as! NSFetchedResultsController<CartModel>
    } ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainViewController._instance = self
        
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        
        do {
            try fetchedColorSetResultsController.performFetch()
            if let cs = fetchedColorSetResultsController.fetchedObjects {
                MainViewController.colorSets = cs
                
                if (Tools.isFirstOpen()) {
                    fetchTrends()
                }
            }
            
            try fetchedCartResultsController.performFetch()
            if let carts = fetchedCartResultsController.fetchedObjects {
                MainViewController.carts = carts
                kCartCount = Tools.getCartsCount(carts)
            }
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
        
        fetchedColorSetResultsController.delegate = self
        fetchedCartResultsController.delegate = self
    }
    
    func fetchTrends() {
        startIndicator()
        TrendClient.loadTrends() { err, trends in
            self.stopIndicator()
            
            if let trends = trends {
                Tools.setFirstOpen()
                
                for trend in trends {
                    let saveColor = ColorSet(name: trend.name, note: trend.description, favourite: false, context: self.sharedContext)
                    for (colorName, percent) in trend.colors {
                        let _ = Color(
                            name: colorName,
                            percent: percent,
                            colorSet: saveColor,
                            context: self.sharedContext)
                    }
                    
                    //MainViewController.colorSets.append(saveColor)
                }
                
                MainViewController.saveDatabase()
            } else {
                Tools.showAlert(self, "No Connection", "There seems to be a problem with your connection.")
            }
        }
    }
    
    func startIndicator() {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.white
    }
    
    func stopIndicator() {
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            break
//            do {
//                try fetchedColorSetResultsController.performFetch()
//                if let cs = fetchedColorSetResultsController.fetchedObjects {
//                    MainViewController.colorSets = cs
//                }
//            } catch {
//                print("Unresolved error \(error)")
//                abort()
//            }
        case .insert:
            break
//            let cs = self.fetchedColorSetResultsController.object(at: newIndexPath! as IndexPath)
//            self.colorSets.append(cs)
        case .delete:
            break
//            self.colorSets.remove(at: (indexPath?.item)!)
            
        default:
            return
        }
    }
    
    func reloadDatabase() {
        do {
            try fetchedColorSetResultsController.performFetch()
            if let cs = fetchedColorSetResultsController.fetchedObjects {
                MainViewController.colorSets = cs
            }
            
            try fetchedCartResultsController.performFetch()
            if let carts = fetchedCartResultsController.fetchedObjects {
                MainViewController.carts = carts
                kCartCount = Tools.getCartsCount(carts)
                
                if (kActiveViewController != nil) {
                    (kActiveViewController as! BaseViewController).refreshCartNumber()
                }
            }
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
    }
    
    static public func saveDatabase() {
        CoreDataStackManager.sharedInstance().saveContext()
        Instance.reloadDatabase()
    }
    
    static func insertColorset(name: String, selections: [Int: Int]!) -> Int {
        let colorSet = ColorSet(name: name, note: "", favourite: false, context: Instance.sharedContext)
        for (colorId, percent) in selections {
            let _ = Color(
                name: ColorArray[colorId],
                percent: percent,
                colorSet: colorSet,
                context: Instance.sharedContext)
        }
        
        saveDatabase()        
        return colorSets.count - 1
    }
    
    static func insertColorset(name: String, note: String, selections: [String: Int]!) -> Int {
        let colorSet = ColorSet(name: name, note: note, favourite: false, context: Instance.sharedContext)
        for (colorName, percent) in selections {
            let _ = Color(
                name: colorName,
                percent: percent,
                colorSet: colorSet,
                context: Instance.sharedContext)
        }
        
        saveDatabase()
        return colorSets.count - 1
    }
    
    static func updateColorset(index: Int, name: String, selections: [Int: Int]!) {
        let colorSet:ColorSet = colorSets[index]
        
        //print(set.name)
        colorSet.name = name
        
        for item in colorSet.colors {
            Instance.sharedContext.delete(item)
        }
        
        for (colorId, percent) in selections {
            let _ = Color(
                name: ColorArray[colorId],
                percent: percent,
                colorSet: colorSet,
                context: Instance.sharedContext)
        }
        
        saveDatabase()
    }
    
    static func deleteColorset(colorSet: ColorSet?) {
        CoreDataStackManager.sharedInstance().managedObjectContext.delete(colorSet!)
        CoreDataStackManager.sharedInstance().saveContext()
        
        saveDatabase()
    }
    
    
    static func insertCart(colorSet: ColorSet, finish: String, size: String, quantity: Int, price: Float) {
        _ = CartModel(colorSet: colorSet, finish: finish, size: size, quantity: quantity, price: price, context: Instance.sharedContext)
        
        saveDatabase()
    }
    
    static func updateCart(index: Int, cart: CartModel) {
        let oldCart:CartModel = carts[index]
        
        oldCart.quantity = cart.quantity
        
        saveDatabase()
    }
    
    static func deleteCart(cart: CartModel?) {
        CoreDataStackManager.sharedInstance().managedObjectContext.delete(cart!)
        CoreDataStackManager.sharedInstance().saveContext()
        
        saveDatabase()
    }
}
