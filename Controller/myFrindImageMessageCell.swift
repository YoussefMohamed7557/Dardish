//
//  myFrindImageMessageCell.swift
//  Dardish
//
//  Created by Youssef on 07/04/2022.
//

import UIKit

class myFrindImageMessageCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var recieveDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
