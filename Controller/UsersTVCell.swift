//
//  UsersTVC.swift
//  Dardish
//
//  Created by Youssef on 17/12/2021.
//

import UIKit

class UsersTVCell: UITableViewCell {
    
    @IBOutlet weak var cellProfilImage: UIImageView!
    @IBOutlet weak var cellUserNameLBL: UILabel!
    @IBOutlet weak var email: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
