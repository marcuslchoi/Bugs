//
//  CreateIssueTableViewCell.swift
//  BugTracker
//
//  Created by Marcus Choi on 5/5/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class CreateIssueTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    @IBOutlet weak var cellColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellColorView.layer.cornerRadius = cellColorView.frame.size.height / 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
