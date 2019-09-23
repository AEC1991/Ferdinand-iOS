//
//  CartViewController.swift
//  Ferdinand
//
//  Created by alex on 4/1/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import Foundation
import SwiftyJSON


class CartViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, CartCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSubTotal: UILabel!
    
    var mCarts = [CartModel]()
    var editIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad(showCartButton: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mCarts = MainViewController.carts
        self.tableView.reloadData()
        refreshData()
        
        
        self.startIndicator()
        WebService.GetAllCarts{ successed, json in
            self.stopIndicator()
            
            if successed == false {
                return
            }
            
            //print(json)
            
            let cartItems = json["items"].array
            for item in cartItems! {
                //print(item)
                
//                let cart = CartModel()
//                cart.quantity = json["quantity"].int!
//
//                let jsonProps = item["properties"]
//                cart.finish = jsonProps["Finish"].string!
//                cart.price = jsonProps["line_price"].floatValue / 100
//
//                self.mCarts.append(cart)
//
//                print(item["title"]) // "http://httpbin.org/get"
            }
            
            self.tableView.reloadData()
            self.refreshData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mCarts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        cell.initParam(cart: mCarts[indexPath.row])
        cell.cellDelegate = self
        cell.index = indexPath.row
        
        return cell
    }
    
    func didRemovePressed(_ tag: Int) {
        let index = tag
        if (mCarts.count <= index) {
            return
        }
        
        let cart = mCarts[index]
        
        self.startIndicator()
        WebService.updateQuantity(index+1, 0, completion: { successed, json in
            self.stopIndicator()
            
            if successed == false {
                return
            }
            
            MainViewController.deleteCart(cart: cart)
            self.mCarts = MainViewController.carts
            
            self.tableView.reloadData()
            self.refreshData()
        })
    }
    
    func didFinishPressed(_ tag: Int) {
        let index = tag
        let cart = mCarts[index]
        
        alertAndBuy(nil, completion: { finish in
            if (cart.finish == finish) {
                return
            }
            
            cart.finish = finish
            
            self.startIndicator()
            WebService.updateProperties(index+1, cart, completion: { successed, json in
                self.stopIndicator()
                
                if successed == false {
                    return
                }
                
                MainViewController.updateCart(index: index, cart: cart)
                self.tableView.reloadData()
                self.refreshData()
            })
        })
    }
    
    func didSizePressed(_ tag: Int) {
        let index = tag
        let cart = mCarts[index]
        
        alertAndBuy2(nil, cart.finish, completion: { productId, size, price in
            if (cart.size == size) {
                return
            }
            
            self.startIndicator()
            WebService.updateQuantity(index+1, 0, completion: { successed, json in
                if successed == false {
                    self.stopIndicator()
                    return
                }
                
                let textJson = Tools.cartContent(cart.colorSet, cart.finish, productId, cart.quantity)
                WebService.addToCart(textJson, completion: { successed, json in
                    self.stopIndicator()
                    
                    if successed == false {
                        return
                    }
                    
                    MainViewController.insertCart(colorSet: cart.colorSet, finish: cart.finish, size: size, quantity: cart.quantity, price: price)
                    MainViewController.deleteCart(cart: cart)
                    
                    self.mCarts = MainViewController.carts
                    self.tableView.reloadData()
                    self.refreshData()
                })
            })
        })
    }
    
    func didDecQuantityPressed(_ tag: Int) {
        let index = tag
        let cart = mCarts[index]
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! CartCell
        
        if (cart.quantity == 1) {
            let refreshAlert = UIAlertController(title: "Message", message: "Are you sure want to delete?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction!) in
                self.didRemovePressed(tag)
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                //print("Handle Cancel Logic here")
            }))
            
            self.present(refreshAlert, animated: true, completion: nil)
            return
        }
        
        cart.quantity = cart.quantity - 1
        cell.setQuantity(value: cart.quantity)
        
        self.startIndicator()
        WebService.updateQuantity(index+1, cart.quantity, completion: { successed, json in
            self.stopIndicator()
            
            if successed == false {
                return
            }
            
            MainViewController.updateCart(index: index, cart: cart)
            self.refreshData()
        })
    }
    
    func didIncQuantityPressed(_ tag: Int) {
        let index = tag
        let cart = mCarts[index]
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! CartCell
        
        cart.quantity = cart.quantity + 1
        cell.setQuantity(value: cart.quantity)
        
        self.startIndicator()
        WebService.updateQuantity(index+1, cart.quantity, completion: { successed, json in
            self.stopIndicator()
            
            if successed == false {
                return
            }
            
            MainViewController.updateCart(index: index, cart: cart)
            self.refreshData()
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 213.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func refreshData() {
        recalcSubTotal()
    }
    
    func recalcSubTotal() {
        var subtotal : Float = 0
        
        for item in mCarts {
            subtotal += item.price * (Float)(item.quantity)
        }
        
        lblSubTotal.text = String.init(format: "$%.2f", subtotal)
    }
    
    @IBAction func onCheckoutEvent(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController

        self.navigationController?.pushViewController(vc, animated: true)
    }
}

protocol CartCellDelegate : class {
    func didRemovePressed(_ tag: Int)
    func didFinishPressed(_ tag: Int)
    func didSizePressed(_ tag: Int)
    func didDecQuantityPressed(_ tag: Int)
    func didIncQuantityPressed(_ tag: Int)
}

class CartCell: UITableViewCell {
    @IBOutlet weak var mixView: CircleView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mixLabel: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    
    @IBOutlet weak var lblFinish: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var btnDecQty: UIButton!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var btnIncQty: UIButton!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var favView: UIImageView!

    var cart: CartModel?
    var index: Int?
    
    func initParam(cart: CartModel) {
        self.cart = cart
        
        btnRemove.backgroundColor = .clear
//        btnRemove.layer.cornerRadius = 3
        btnRemove.layer.borderWidth = 1
        btnRemove.layer.borderColor = UIColor.black.cgColor
        
        //print(colorSet.colors)
        nameLabel.text = cart.colorSet.name
        mixLabel.text = cart.colorSet.breakdown
        mixView.backColor = cart.colorSet.uiColor
        
        lblFinish.text = cart.finish
        lblSize.text = cart.size
        setQuantity(value: cart.quantity)
        lblPrice.text = String.init(format: "$%.2f", cart.price)
    }
    
    func setQuantity(value: Int) {
        lblQuantity.text = String.init(format: "%d", value)
    }
    
    
    
    weak var cellDelegate: CartCellDelegate?
    
    // connect the button from your cell with this method
    @IBAction func onRemovePressed(_ sender: UIButton) {
        cellDelegate?.didRemovePressed(index!)
    }
    
    @IBAction func onFinishPressed(_ sender: Any) {
        cellDelegate?.didFinishPressed(index!)
    }
    
    @IBAction func onSizePressed(_ sender: Any) {
        cellDelegate?.didSizePressed(index!)
    }
    
    @IBAction func onDecPressed(_ sender: Any) {
        cellDelegate?.didDecQuantityPressed(index!)
    }
    
    @IBAction func onIncPressed(_ sender: Any) {
        cellDelegate?.didIncQuantityPressed(index!)
    }
}
