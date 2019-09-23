//
//  MediaCell.swift
//  Ferdinand
//
//  Created by iOS Developer on 3/5/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import UIKit
import BMPlayer
import FLAnimatedImage


class MediaCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playerView: BMCustomPlayer!
    @IBOutlet weak var animatedImageView: FLAnimatedImageView!
    
    func setParam(_ url: String) {
        self.layoutSubviews()
        self.layoutIfNeeded()
        
        playerView.isHidden = true
        imageView.isHidden = true
        animatedImageView.isHidden = true
        
        if ((url.lowercased().range(of: ".gif?")) != nil) {
            let imageURL = UIImage.gifImageWithURL(url)
            self.imageView.image = imageURL
            self.imageView.isHidden = false
            
//            do {
//                self.animatedImageView.isHidden = false
//                let image: FLAnimatedImage?
//                try image = FLAnimatedImage.init(animatedGIFData: Data(contentsOf: URL(string: url)!))
//                self.animatedImageView.animatedImage = image
//            } catch {
//                print(error)
//            }
        } else if ((url.lowercased().range(of: ".mp4?")) != nil) {
            playerVCAccessNetwork(url)
            
            self.playerView.isHidden = false
        } else {
            self.imageView.downloadedFrom(link: url)
            
            self.imageView.isHidden = false
        }
    }
    
    func playerVCAccessNetwork(_ videoUrl: String) {
        let asset = BMPlayerResource(url: URL(string: videoUrl)!,
                                     name: "",
                                     cover: nil,
                                     subtitle: nil)
        playerView.setVideo(resource: asset)
    }
}
