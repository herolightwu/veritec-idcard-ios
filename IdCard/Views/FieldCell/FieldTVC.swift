//
//  FieldTVC.swift
//  IdCard
//
//  Created by XiangHao on 1/3/24.
//

import UIKit
import DTTextField

class FieldTVC: UITableViewCell {
    
    @IBOutlet weak var fieldTxt: DTTextField!
    
    var data: Field!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fieldTxt.borderColor = UIColor(rgb: 0x6D8EB5)
        fieldTxt.placeholderColor = .black
        fieldTxt.floatPlaceholderColor = .black
        fieldTxt.floatPlaceholderActiveColor = .black
        fieldTxt.textColor = .gray
        fieldTxt.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reloadData() {
        fieldTxt.placeholder = data.placeholder
        fieldTxt.text = data.value
    }
    
    func setEditable(bEdit: Bool) {
        if bEdit {
            fieldTxt.isUserInteractionEnabled = true
            fieldTxt.textColor = .black
        } else {
            fieldTxt.isUserInteractionEnabled = false
            fieldTxt.textColor = .gray
        }
    }
    
}
