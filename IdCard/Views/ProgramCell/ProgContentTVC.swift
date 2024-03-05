//
//  ProgContentTVC.swift
//  IdCard
//
//  Created by XiangHao on 1/5/24.
//

import UIKit

class ProgContentTVC: UITableViewCell {

    @IBOutlet weak var frontImg: UIImageView!
    @IBOutlet weak var titleLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        frontImg.dropShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
