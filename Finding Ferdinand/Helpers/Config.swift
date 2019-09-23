//
//  Commons.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/7/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit

var ColorDictionary = [
    "Nob Hill Red": UIColor(red: 0.7960784314, green: 0.03529411765, blue: 0.1137254902, alpha: 1),
    "Red Fantasy": UIColor(red: 0.8352941176, green: 0.03921568627, blue: 0.2274509804, alpha: 1),
    "Classic Coral": UIColor(red: 0.9019607843, green: 0.2156862745, blue: 0.3058823529, alpha: 1),
    "Creamy Mauve": UIColor(red: 254.0/255.0, green: 104.0/255.0, blue: 111.0/255.0, alpha: 1),
    "Tequila Sunrise": UIColor(red: 0.9333333333, green: 0.168627451, blue: 0.1254901961, alpha: 1),
    "Orange Flare": UIColor(red: 0.9450980392, green: 0.4549019608, blue: 0.2941176471, alpha: 1),
    "Au Naturel": UIColor(red: 0.7568627451, green: 0.5176470588, blue: 0.4745098039, alpha: 1),
    "Mauvelous": UIColor(red: 0.7215686275, green: 0.4509803922, blue: 0.4823529412, alpha: 1),
    "Orange Sorbet": UIColor(red: 0.8862745098, green: 0.2039215686, blue: 0.1019607843, alpha: 1),
    "Orange Toffee": UIColor(red: 211.0/255.0, green: 71.0/255.0, blue: 2.0/255.0, alpha: 1),
    "Barely There": UIColor(red: 200.0/255.0, green: 106.0/255.0, blue: 93.0/255.0, alpha: 1),
    "Ruby Rust": UIColor(red: 173.0/255.0, green: 87.0/255.0, blue: 75.0/255.0, alpha: 1),
    "Cranberry": UIColor(red: 0.7411764706, green: 0.1215686275, blue: 0.368627451, alpha: 1),
    "Magenta Pop": UIColor(red: 0.8392156863, green: 0.1333333333, blue: 0.5215686275, alpha: 1),
    "Pink Pizazz": UIColor(red: 0.8274509804, green: 0.2039215686, blue: 0.5019607843, alpha: 1),
    "Toffee": UIColor(red: 156.0/255.0, green: 60.0/255.0, blue: 30.0/255.0, alpha: 1),
    "Berry Jam": UIColor(red: 0.4745098039, green: 0.1803921569, blue: 0.3803921569, alpha: 1),
    "Flaming Fuchsia": UIColor(red: 0.6823529412, green: 0.1490196078, blue: 0.5215686275, alpha: 1),
    "Bing Cherry": UIColor(red: 0.5529411765, green: 0.05098039216, blue: 0.09803921569, alpha: 1),
    "Sinful": UIColor(red: 0.4431372549, green: 0.1058823529, blue: 0.137254902, alpha: 1),
    "Coffee Bean": UIColor(red: 92.0/255.0, green: 4.0/255.0, blue: 29.0/255.0, alpha: 1),
    "Truffle": UIColor(red: 68.0/255.0, green: 12.0/255.0, blue: 1.0/255.0, alpha: 1),
    "White": UIColor.white,
    "Black": UIColor.black,
    "Blue": UIColor.blue
]

var ColorArray:Array = [
    "Nob Hill Red",
    "Red Fantasy",
    "Classic Coral",
    "Creamy Mauve",
    "Tequila Sunrise",
    "Orange Flare",
    "Au Naturel",
    "Mauvelous",
    "Orange Sorbet",
    "Orange Toffee",
    "Barely There",
    "Ruby Rust",
    "Cranberry",
    "Magenta Pop",
    "Pink Pizazz",
    "Toffee",
    "Berry Jam",
    "Flaming Fuchsia",
    "Bing Cherry",
    "Sinful",
    "Coffee Bean",
    "Truffle",
    "White",
    "Black",
    "Blue"
]
//var ColorArray = Array(ColorDictionary.keys)

let kSelectColorLimit = 4 // limit of select colors
let kColorNameLengthLimit = 20 // limit of select colors

let TrendsURL = "https://ferdinand-6b085.firebaseio.com/trends.json"

let kAppId = "1193085629"

//let kWebServerURL = "https://s-o-dev-ff.myshopify.com"
//let kUser       = "2a7be4bbcad72826d46be0f49d4796e7"    // API Key
//let kPassword   = "d3c937f75b9a4046d1601555eb5b6cab"    // Password
//let kStorefrontAccessToken = "e5b94e99939cbc59bd7a9003d234e8a5"

let kWebServerURL = "https://www.findingferdinand.com"
let kUser       = "3523fdc1dad31c353f9d3edfc5e4d194"    // API Key
let kPassword   = "28b8628004ad9194713a31fc2ca5452e"    // Password
let kStorefrontAccessToken = "39d840a8de08286997a2f5aef28c2ab2"


let kFullProductId = "8646192955508"
let kMiniProductId = "8646214451316"

let kCreamy = "Creamy"
let kMatte = "Matte"
let kSheer = "Sheer"

let kMini = "Mini"
let kFull = "Full"

let kPinkColor = UIColor(red: 255.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1)

var kSelectIndex : Int = -1
var kCartCount : Int = 0
var kActiveViewController : UIViewController?
