//
//  myFriendMessage.swift
//  Dardish
//
//  Created by Youssef on 02/02/2022.
//

import UIKit

class myFriendMessageCell: UITableViewCell {
    @IBOutlet weak var messageLBL: UILabel!
    @IBOutlet weak var dateLBL: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
