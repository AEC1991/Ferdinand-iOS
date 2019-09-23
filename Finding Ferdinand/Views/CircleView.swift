//
//  CircleView.swift
//  Ferdinand
//
//  Created by alex on 3/13/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import Foundation

@IBDesignable class CircleView : UIView {

    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!

    @IBInspectable var title: String = "" {
        didSet {
            lblTitle.text = title
        }
    }
    
    @IBInspectable var backColor: UIColor = UIColor.blue {
        didSet {
            self.view.backgroundColor = backColor
            if (backColor == UIColor.white) {
                self.lblTitle.textColor = UIColor.black
            } else {
                self.lblTitle.textColor = UIColor.white
            }
        }
    }
    
    @IBInspectable var check: Bool = false {
        didSet {
            self.imgCheck.isHidden = !check
        }
    }
    
    
    var view: UIView!
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        addSubview(view)
        self.view = view
    }
    
    override func layoutSubviews() {        
        makeCircle()
    }
    
    func makeCircle() {
        layer.cornerRadius = bounds.width / 2
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        contentMode = UIViewContentMode.scaleAspectFill
        clipsToBounds = true
    }
    
    func showProperty(visible: Bool) {
        lblTitle.isHidden = !visible
        imgCheck.isHidden = !visible
    }
    
    func hideBorder() {
        layer.borderWidth = 0
    }
}
