//
//  IntroViewController.swift
//  Ferdinand
//
//  Created by alex on 3/21/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class IntroViewController: UIViewController {
    
    @IBOutlet weak var introCollection: UICollectionView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var lblStatus: UILabel!
    
    var showPageCount: Int = 1
    
    var imageArray: [String] = [
        "intro_main"
    ]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureGallery()
        configurePageControl()
    }
    
    @IBAction func onCloseBtnEvent(_ sender: Any) {
        if (showPageCount < imageArray.count) {
            return
        }
        
        PrefHelper.setFirstOpen(true)

        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.setRootVCForSignIn()
    }
    
    func updateShownPageCount(_ index: Int) {
        if (showPageCount > index) {
            return
        }
        
        showPageCount = index + 1
        if (showPageCount == imageArray.count) {
            lblStatus.isHidden = true
        }
        
    }
}

extension IntroViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func configureGallery() {
        introCollection.delegate = self
        introCollection.dataSource = self
    }
    
    func configurePageControl() {
        pageIndicator.numberOfPages = imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == introCollection) {
            return imageArray.count
        }
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == introCollection) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IntroCell", for: indexPath) as! IntroCell
            let index = indexPath.row
            
            cell.setImage(imageArray[index])
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == introCollection) {
            let screenSize = collectionView.bounds.size
            return screenSize
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scrollViewDidScroll")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == introCollection) {
            let index = Int(introCollection.contentOffset.x / introCollection.frame.size.width)
            pageIndicator.currentPage = index
            
            updateShownPageCount(index)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //print("scrollViewDidEndDragging")
    }
    
}

