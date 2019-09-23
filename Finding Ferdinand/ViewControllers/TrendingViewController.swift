//
//  TrendingViewController.swift
//  Ferdinand
//
//  Created by Ashwin Hamal on 8/7/16.
//  Copyright © 2016 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit

class TrendingViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var trends = [Trend]()
    
    override func viewDidLoad() {
        super.viewDidLoad(showCartButton: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchTrends()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrendCell") as! TrendCell
        cell.setTrend(trends[indexPath.row])
        return cell
    }

    func fetchTrends() {
        startIndicator()
        TrendClient.loadTrends() { err, trends in
            self.stopIndicator()
            if let trends = trends {
                self.trends = trends
                self.tableView.reloadData()
            } else {
                Tools.showAlert(self, "No Connection", "There seems to be a problem with your connection.")
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrendingDetailViewController") as! TrendingDetailViewController
        vc.trend = trends[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class TrendCell: UITableViewCell {
    @IBOutlet weak var colorView: CircleView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setTrend(_ trend: Trend) {
        nameLabel.text = trend.name
        descriptionLabel.text = trend.description
        colorView.backColor = trend.uiColor
    }
}
