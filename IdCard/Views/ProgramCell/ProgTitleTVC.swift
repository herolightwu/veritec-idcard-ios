//
//  ProgTitleTVC.swift
//  IdCard
//
//  Created by XiangHao on 1/5/24.
//

import UIKit

class ProgTitleTVC: UITableViewCell {
    
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Animations
    func openArrow(){
        UIView.animate(withDuration: 0.25, animations: {
            self.arrowImg.transform = CGAffineTransform(rotationAngle: (CGFloat(Double.pi) / 180.0)*0.0);
        })
    }
    
    func closeArrow(){
        UIView.animate(withDuration: 0.25, animations: {
            self.arrowImg.transform = CGAffineTransform(rotationAngle: (CGFloat(Double.pi) / 180.0)*180.0);
        })
    }
    
}
