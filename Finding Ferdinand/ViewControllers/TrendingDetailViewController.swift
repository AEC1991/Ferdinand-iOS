//
//  TrendingDetailViewController.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/14/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import BMPlayer


class TrendingDetailViewController: BaseViewController {
    
    @IBOutlet weak var colorView: CircleView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playerView: BMCustomPlayer!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var breakdownLabel: UILabel!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var mediaCollection: UICollectionView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    

    var trend: Trend!
    
    override func viewDidLoad() {
        super.viewDidLoad(showCartButton: true)
        
        colorView.backColor = trend.uiColor
        nameLabel.text = trend.name
        descriptionText.text = trend.description
        breakdownLabel.text = trend.breakdown
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureGallery()
        configurePageControl()
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        MainViewController.insertColorset(name: trend.name, note: trend.description, selections: trend.colors)

        let alert = UIAlertController(title: "SAVED!", message: "You can buy and edit your colors in the \"View Mixes\" tab.", preferredStyle: UIAlertControllerStyle.alert)
        
        let openColorTab = UIAlertAction(title: "View Mixes", style: UIAlertActionStyle.default) { _ in
            self.tabBarController?.selectedIndex = 1
        }
        
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(openColorTab)
        self.present(alert, animated: true, completion: nil)
    }
}


extension TrendingDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func configureGallery() {
        mediaCollection.delegate = self
        mediaCollection.dataSource = self
    }
    
    func configurePageControl() {
        pageIndicator.numberOfPages = trend.images.count == 1 ? 0:trend.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == mediaCollection) {
            return trend.images.count
        }
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == mediaCollection) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
            let index = indexPath.row
            
            cell.setParam(trend.images[index])
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == mediaCollection) {
            let screenSize = collectionView.bounds.size
            return screenSize
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == mediaCollection) {
            let index = Int(mediaCollection.contentOffset.x / mediaCollection.frame.size.width)
            pageIndicator.currentPage = index
        }
    }
}
