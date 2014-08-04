//
//  ApplicationCell.swift
//  ApplicationListDemo
//
//  Created by Sword on 8/3/14.
//  Copyright (c) 2014 Sword. All rights reserved.
//

import UIKit

class ApplicationCell: UITableViewCell {

    var application:Application?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLabel.text = self.application?.name
        self.detailLabel.text = self.application?.desc
        var icon = self.application?.icon
        if icon {
            NSLog(icon!)
        }
        let url:NSURL? = NSURL.URLWithString(self.application?.icon)
        if url {
            self.iconImageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "icon"))
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
