//
//  MixerViewController.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/7/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit

class MixerViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mixView: CircleView!
    @IBOutlet weak var colorsView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    var selections: [Int: Int]! = [Int: Int]()
    
    var name: String!
    var isUpdate:Bool?
    var colorIndex:Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad(showCartButton: true)
        
        mixView.showProperty(visible: false)
        colorsView.allowsMultipleSelection = true
        setFlowLayout()
        updateVC()
    }
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    func setFlowLayout() {
//        let dim = CGFloat(80.0) // (colorsView.frame.width) / 4.0 - 1.0
//        flowLayout.minimumInteritemSpacing = 0.0
//        flowLayout.minimumLineSpacing = 1.0
//        flowLayout.itemSize = CGSizeMake(dim, dim)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    // Data Source
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MixerColorViewCell", for: indexPath) as! MixerColorViewCell
        let name = ColorArray[indexPath.item]
        let color = ColorDictionary[name]!
        
        cell.setCell(name, color: color, selected: selections[indexPath.item] != nil)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ColorDictionary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MixerColorViewCell
        if selections.keys.count == kSelectColorLimit {
            infoLabel.text = "ONLY 4 COLORS ALLOWED"
            infoLabel.textColor = UIColor(rgb: 0x2797d9, a: 1.0)
            UIView.animate(withDuration: 1.0, animations: {
                self.infoLabel.alpha = 1.0
                self.mixView.isHidden = true
                self.infoLabel.isHidden = false
            }, completion: { _ in
                UIView.animate(withDuration: 1.0, animations: {
                    self.infoLabel.alpha = 0.0
                }, completion: { _ in
                    self.mixView.isHidden = false
                    self.infoLabel.isHidden = true
                })
            })
            return
        }
        
        cell.palette.check = true
        selections[indexPath.item] = 100
        updateVC()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MixerColorViewCell
        cell.palette.check = false
        selections.removeValue(forKey: indexPath.item)
        
        updateVC()
    }
    
    func updateVC() {
        let right = selections.count >= 1 && selections.count <= 4
        
        if right {
            var mixList = [(UIColor, Int)]()
            for (i, _) in selections {
                let color = ColorDictionary[ColorArray[i]]!
                mixList.append((color, 100))
            }
            let color = Tools.mixColors(mixList)
            mixView.backColor = color
        }
        mixView.isHidden = !right
        infoLabel.isHidden = right
        if right == false {
            infoLabel.alpha = 1.0
            infoLabel.text = "Select up to 4 colors"
            infoLabel.textColor = UIColor.black
        } else {
            infoLabel.alpha = 0.0
        }
        nextButton.isHidden = !right
    }

    @IBAction func next(_ sender: UIButton) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "MixerDetailViewController") as! MixerDetailViewController
        detailVC.isUpdate = self.isUpdate
        detailVC.selections = self.selections
        detailVC.name = self.name
        detailVC.colorIndex = self.colorIndex
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

class MixerColorViewCell: UICollectionViewCell {
    @IBOutlet weak var palette: CircleView!

    func setCell(_ name: String, color: UIColor, selected: Bool) {
        palette.title = name
        palette.backColor = color
        palette.check = selected
    }
}

