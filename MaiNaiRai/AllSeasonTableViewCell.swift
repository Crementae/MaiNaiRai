//
//  SummerTableViewCell.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 12/2/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//

import UIKit

class AllSeasonTableViewCell: UITableViewCell {
    
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var sciNameLabel: UILabel!
    @IBOutlet var localNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


