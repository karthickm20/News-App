//
//  NewsTableViewCell.swift
//  News App
//
//  Created by Karthick M on 06/11/23.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet var newsContent: UILabel!
    @IBOutlet var published: UILabel!
    @IBOutlet var cellView: UIView!
    @IBOutlet var newsImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 10
        cellView.layer.masksToBounds = true
        newsImage.layer.cornerRadius = 10
        newsImage.layer.masksToBounds = true
    }
    
}
