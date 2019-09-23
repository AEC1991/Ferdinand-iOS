//
//  IntroCell.swift
//  Ferdinand
//
//  Created by iOS Developer on 3/5/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import UIKit

class IntroCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(_ imageName: String) {
        self.layoutSubviews()
        self.layoutIfNeeded()
        
        imageView.image = UIImage(named: imageName)
    }
}
