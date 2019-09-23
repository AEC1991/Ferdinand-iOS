//
//  MixerDetailController.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/14/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class MixerDetailViewController: BaseViewController, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var mixView: CircleView!
    @IBOutlet weak var mixTable: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameField: UITextField!

    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!

    var selections: [Int: Int]!
    var name: String!
    var isUpdate:Bool?
    var colorIndex:Int!

    override func viewDidLoad() {
        super.viewDidLoad(showCartButton: true)
        
        mixView.showProperty(visible: false)
        updateMixColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isUpdate == true {
            self.nameField.text = self.name
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        if (textField == nameField) {
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= kColorNameLengthLimit
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorSliderCell") as! ColorSliderCell
        let key = Array(selections.keys)[indexPath.row]
        cell.setSelection(key, percent: selections[key]!, mvc: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selections.keys.count
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func updatePercent(_ colorId: Int, percent: Int) {
        selections[colorId] = percent
        updateMixColor()
    }
    
    func updateMixColor() {
        var mixList = [(UIColor, Int)]()
        for (colorId, percent) in selections {
            let color = ColorDictionary[ColorArray[colorId]]!
            mixList.append((color, percent))
        }
        let color = Tools.mixColors(mixList)
        mixView.backColor = color
    }

    @IBAction func onSaveTap(_ sender: UIButton) {
        if !checkError() { return }
        
        if isUpdate == true {
            MainViewController.updateColorset(index: self.colorIndex, name: self.nameField.text!, selections: self.selections)
            
            let alert = UIAlertController(title: "Updated!", message: "You're all set.\nThe color is saved.", preferredStyle: UIAlertControllerStyle.alert)
            let openColorTab = UIAlertAction(title: "View Mixes", style: UIAlertActionStyle.default) { _ in
                self.tabBarController?.selectedIndex = 1
                self.navigationController?.popToRootViewController(animated: true)
            }
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            alert.addAction(openColorTab)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.colorIndex = MainViewController.insertColorset(name: nameField.text!, selections: self.selections)
            self.name = nameField.text!
            isUpdate = true
            
            let alert = UIAlertController(title: "SAVED!", message: "You can buy and edit your colors in the \"View Mixes\" tab.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "View Mixes", style: UIAlertActionStyle.default) { _ in
                self.tabBarController?.selectedIndex = 1
            })
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkError() -> Bool {
        if  (nameField.text == "") {
            errorLabel.text = "PLEASE SPECIFY A NAME"
            UIView.animate(withDuration: 1.0, animations: {
                self.errorLabel.alpha = 1.0
                self.nameField.isHidden = true
                self.errorLabel.isHidden = false
            }, completion: { _ in
                UIView.animate(withDuration: 1.0, animations: {
                    self.errorLabel.alpha = 0.0
                }, completion: { _ in
                    self.errorLabel.isHidden = true
                    self.nameField.isHidden = false
                })
            })
            
            return false
        }
        
        return true
    }
}

class ColorSliderCell: UITableViewCell {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var colorView: CircleView!
    @IBOutlet weak var percentLabel: UILabel!

    var mvc: MixerDetailViewController!
    var colorName: String!
    var colorId: Int!
    
    func setSelection(_ colorId: Int, percent: Int, mvc: MixerDetailViewController) {
        self.colorId = colorId
        self.mvc = mvc
        
        colorName =  ColorArray[colorId]
        percentLabel.text = "\(percent)%"
        colorView.backColor = ColorDictionary[colorName]!
        colorView.title = colorName
        slider.value = Float(percent)
    }

    @IBAction func onChange(_ sender: UISlider) {
        let percent = min(Int((sender.value) / 10.0), 100) * 10
        percentLabel.text = "\(percent)%"
        mvc.updatePercent(colorId, percent: percent)
    }
}

