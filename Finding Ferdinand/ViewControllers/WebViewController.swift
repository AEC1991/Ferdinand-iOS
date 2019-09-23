//
//  CartViewController.swift
//  Ferdinand
//
//  Created by alex on 4/1/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import Foundation

class WebViewController: BaseViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!

    let targetUrl : String = "\(kWebServerURL)/cart"

    override func viewDidLoad() {
        super.viewDidLoad(showCartButton: false)

        startIndicator()

        let url : NSURL! = NSURL(string: targetUrl)
        webView.loadRequest(URLRequest(url: url as URL))
        webView.isOpaque = false;
        webView.backgroundColor = UIColor.clear
        webView.scalesPageToFit = true;
        webView.delegate = self// Add this line to set the delegate of webView
    }

    func webViewDidFinishLoad(_ webView : UIWebView) {
        //Page is loaded do what you want
        stopIndicator()
    }
}
