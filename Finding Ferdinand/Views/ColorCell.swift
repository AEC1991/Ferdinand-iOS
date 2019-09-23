//
//  ColorCell.swift
//  Ferdinand
//
//  Created by iOS Developer on 3/5/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import UIKit


class ColorCell: UICollectionViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var colorView: CircleView!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cellWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtTopConstraint: NSLayoutConstraint!
    
    func setColorSet(colorSet: ColorSet?) {
        self.layoutSubviews()
        self.layoutIfNeeded()
        
        if (colorSet != nil) {
            lblName.text = colorSet?.name
            colorView.backColor = (colorSet?.uiColor)!
        } else {
            lblName.text = ""
            colorView.backColor = UIColor.clear
        }
        
        colorView.hideBorder()
    }    
}
