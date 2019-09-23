//
//  MIBadgeButton.swift
//  MIBadgeButton
//
//  Created by Yosemite on 8/27/14.
//  Copyright (c) 2014 Youxel Technology. All rights reserved.
//

import UIKit

public class MIBadgeButton: UIButton {
    
    private var badgeLabel: UILabel
    public var badgeString: String? {
        didSet {
            setupBadgeViewWithString(badgeText: badgeString)
        }
    }
    
    public var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            setupBadgeViewWithString(badgeText: badgeString)
        }
    }
    
    public var badgeBackgroundColor = UIColor.red {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    public var badgeTextColor = UIColor.white {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }

    override public init(frame: CGRect) {
        badgeLabel = UILabel()
        super.init(frame: frame)
        // Initialization code
        setupBadgeViewWithString(badgeText: "")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        badgeLabel = UILabel()
        super.init(coder: aDecoder)
        setupBadgeViewWithString(badgeText: "")
    }
    
    public func initWithFrame(frame: CGRect, withBadgeString badgeString: String, withBadgeInsets badgeInsets: UIEdgeInsets) -> AnyObject {
        
        badgeLabel = UILabel()
        badgeEdgeInsets = badgeInsets
        setupBadgeViewWithString(badgeText: badgeString)
        return self
    }
    
    private func setupBadgeViewWithString(badgeText: String?) {
        badgeLabel.clipsToBounds = true
        badgeLabel.text = badgeText
        badgeLabel.font = UIFont.systemFont(ofSize: 12)
        badgeLabel.textAlignment = .center
        badgeLabel.sizeToFit()
        let badgeSize = badgeLabel.frame.size
        
        let height = max(20, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)
        
        var vertical: Double?, horizontal: Double?
        if let badgeInset = self.badgeEdgeInsets {
            vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
            horizontal = Double(badgeInset.left) - Double(badgeInset.right)
            
            let x = (Double(bounds.size.width) - 10 + horizontal!)
            var y = -(Double(badgeSize.height) / 2) - 10 + vertical!
            if (y < 0) {
                y = 0
            }
            badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        } else {
            let x = self.frame.width - CGFloat((width / 2.0))
            let y = CGFloat(-(height / 2.0))
            badgeLabel.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
        }
        
        setupBadgeStyle()
        addSubview(badgeLabel)
        
        if let text = badgeText {
            badgeLabel.isHidden = text != "" ? false : true
        } else {
            badgeLabel.isHidden = true
        }
        
    }
    
    private func setupBadgeStyle() {
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.textColor = badgeTextColor
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2
    }
}
