//
//  BaseViewController.swift
//  Ferdinand
//
//  Created by alex on 4/1/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import Foundation
import MIBadgeButton_Swift


class BaseViewController: UIViewController {
    var mShowCartButton: Bool?
    var cartBarbuttonItem: MIBadgeButton = MIBadgeButton(frame: CGRect(x:40, y:15, width:60, height:44))
    var indicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func viewDidLoad(showCartButton: Bool) {
        super.viewDidLoad()
        self.navigationItem.titleView = Tools.getNavImage()
        
        if (showCartButton == true) {
            let type1 = type(of: self)
            print("viewDidLoad = '\(type1)'")
            
//            let button = UIButton(type: UIButtonType.custom)
//            button.setImage(UIImage(named: "icon_black_cart"), for: UIControlState.normal)
//            button.addTarget(self, action: #selector(BaseViewController.openCartPage), for: UIControlEvents.touchUpInside)
//            button.frame=CGRect(x: 0, y: 0, width: 48, height: 48)
//            let barButton = UIBarButtonItem(customView: button)
//            self.navigationItem.rightBarButtonItems = [barButton]
            
            _ = cartBarbuttonItem.initWithFrame(frame: CGRect(x:40, y:15, width:60, height:44), withBadgeString: "", withBadgeInsets:  UIEdgeInsetsMake(15, 2, 0, 15))
            cartBarbuttonItem.setImage(UIImage(named: "icon_black_cart"), for: .normal)
            cartBarbuttonItem.setImage(UIImage(named: "icon_black_cart"), for: .selected)
            cartBarbuttonItem.addTarget(self, action: #selector(BaseViewController.openCartPage), for: UIControlEvents.touchUpInside)
            
            let barButton = UIBarButtonItem(customView: cartBarbuttonItem)
            self.navigationItem.rightBarButtonItems = [barButton]
        }
        
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kActiveViewController = self
        refreshCartNumber()
    }
    
    func startIndicator() {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.white
    }
    
    func stopIndicator() {
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }
    
    @objc func openCartPage() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        
        let type1 = type(of: self)
        print("viewcontroller = '\(type1)'")
        self.navigationController?.pushViewController(vc, animated: true)
    }    
    
    func alertAndBuy(_ set: ColorSet?, completion: ((String) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: "Select A Finish", preferredStyle: UIAlertControllerStyle.actionSheet)
        let creamy = UIAlertAction(title: kCreamy, style: UIAlertActionStyle.default) { _ in
            if (set != nil) {
                self.alertAndBuy2(set!, kCreamy)
            } else {
                completion!(kCreamy)
            }
        }
        let matte = UIAlertAction(title: kMatte, style: UIAlertActionStyle.default) { _ in
            if (set != nil) {
                self.alertAndBuy2(set!, kMatte)
            } else {
                completion!(kMatte)
            }
        }
        let sheer = UIAlertAction(title: kSheer, style: UIAlertActionStyle.default) { _ in
            if (set != nil) {
                self.alertAndBuy2(set!, kSheer)
            } else {
                completion!(kSheer)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(creamy)
        alert.addAction(matte)
        alert.addAction(sheer)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertAndBuy2(_ set: ColorSet?, _ finish: String, completion: ((String, String, Float) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: "Add To Cart" + "\n" + "(Select A Size)", preferredStyle: UIAlertControllerStyle.actionSheet)
        let mini = UIAlertAction(title: "Mini Sample $6", style: UIAlertActionStyle.default) { _ in
            if (set != nil) {
                self.buy(set!, finish, kMiniProductId, kMini, 1, 6.0)
            } else {
                completion!(kMiniProductId, kMini, 6.0)
            }
        }
        let full = UIAlertAction(title: "Full Size $30", style: UIAlertActionStyle.default) { _ in
            if (set != nil) {
                self.buy(set!, finish, kFullProductId, kFull, 1, 30.0)
            } else {
                completion!(kFullProductId, kFull, 30.0)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(mini)
        alert.addAction(full)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func buy(_ set: ColorSet?, _ finish: String, _ productId: String, _ size: String, _ quantity: Int, _ price: Float) {
        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        let textJson = Tools.cartContent(set, finish, productId, quantity)
        
        startIndicator()
        WebService.addToCart(textJson, completion: { successed, json in
            self.stopIndicator()
            
            if successed == false {
                return
            }
            
            print(json)
            MainViewController.insertCart(colorSet: set!, finish: finish, size: size, quantity: quantity, price: price)
            self.openViewCartAlert()
        })
    }
    
    func openViewCartAlert() {
        let alert = UIAlertController(title: "Added!", message: "Your color is in the cart.", preferredStyle: UIAlertControllerStyle.alert)
        let openColorTab = UIAlertAction(title: "View Cart", style: UIAlertActionStyle.default) { _ in
            self.openCartPage()
        }
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(openColorTab)
        self.present(alert, animated: true, completion: nil)
    }
    
    func refreshCartNumber() {
        if (kCartCount > 0) {
            cartBarbuttonItem.badgeString = "\(kCartCount)"
        } else {
            cartBarbuttonItem.badgeString = ""
        }
    }
}

