//
//  SavedViewController.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/7/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SavedViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var colorSets = [ColorSet]()
    var editIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad(showCartButton: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        colorSets = MainViewController.colorSets
        
        self.tableView.reloadData()
        
        
        DispatchQueue.global(qos: .background).async {
            sleep(5)
            
            DispatchQueue.main.async() {
                Tools.rateApp(self)
            }
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorSets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedColorCell") as! SavedColorCell
        cell.setColorSet(colorSet: colorSets[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let tryonAction = UIAlertAction(title: "Try On", style: .default) { (action) in
            kSelectIndex = indexPath.row
            self.tabBarController?.selectedIndex = 2            
        }
        menuController.addAction(tryonAction)
        
        let buyAction = UIAlertAction(title: "Add To Cart", style: .default) { (action) in
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) as? SavedColorCell {
                tableView.setEditing(false, animated: true)
                self.alertAndBuy(cell.set!)
            }
        }
        menuController.addAction(buyAction)

        let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
            self.editIndex = indexPath.row

            let selection = self.colorSets[indexPath.row]

            let firstViewController = self.storyboard?.instantiateViewController(withIdentifier: "MixerViewController") as! MixerViewController
            firstViewController.selections = selection.getPercent
            firstViewController.isUpdate = true
            firstViewController.name = selection.name
            firstViewController.colorIndex = self.editIndex

            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MixerDetailViewController") as! MixerDetailViewController
            secondViewController.selections = selection.getPercent
            secondViewController.isUpdate = true
            secondViewController.name = selection.name
            secondViewController.colorIndex = self.editIndex

            //let controllers: [UIViewController] = [firstViewController, secondViewController]
            //self.navigationController?.setViewControllers(controllers, animated: true)

            self.navigationController?.pushViewController(firstViewController, animated: false)
            self.navigationController?.pushViewController(secondViewController, animated: false)
        }
        menuController.addAction(editAction)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            tableView.setEditing(false, animated: true)
            self.doDeleteItem(index: indexPath.row)
        }
        menuController.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        menuController.addAction(cancelAction)
        self.present(menuController, animated: true)
    }

    func doDeleteItem(index: Int) {
        let colorset = self.colorSets[index]
        MainViewController.deleteColorset(colorSet: colorset)

        self.colorSets.remove(at: index)
        self.tableView.reloadData()
    }
}

class SavedColorCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mixLabel: UILabel!
    @IBOutlet weak var mixView: CircleView!
    @IBOutlet weak var favView: UIImageView!
    
    var set: ColorSet?
    
    func setColorSet(colorSet: ColorSet) {
        set = colorSet
        
        nameLabel.text = colorSet.name
        mixLabel.text = colorSet.breakdown
        mixView.backColor = colorSet.uiColor
        favView.isHidden = !colorSet.favourite
    }
}
