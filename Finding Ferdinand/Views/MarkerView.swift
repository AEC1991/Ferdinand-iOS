//
//  MarkerView.swift
//  Ferdinand
//
//  Created by alex on 3/13/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import Foundation

public class MarkerView : UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.layer.cornerRadius = self.frame.size.width/2
        //self.clipsToBounds = true
        
//        self.layer.borderColor = UIColor.clear.cgColor
//        self.layer.borderColor = UIColor.blue.cgColor
//        self.layer.borderWidth = self.frame.size.width/3
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override public func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        let center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        let radius = self.frame.width / 4
        let p = UIBezierPath(ovalIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        
        p.close()
        UIColor.blue.setFill()
        p.fill()
    }
    
    public func changeSize(_ size: CGSize) {
        self.frame = CGRect(origin: self.frame.origin, size: size)
    }
}

