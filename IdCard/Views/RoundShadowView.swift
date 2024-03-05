//
//  RoundShadowView.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/8/23.
//

import UIKit

class RoundShadowView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.refresh()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            self.refresh()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.masksToBounds = false

        self.refresh()
    }

    fileprivate func refresh() {
        var radius = self.cornerRadius
        if self.cornerRadius == 0 {
            radius = self.frame.size.height / 2
        }
        
        self.layer.cornerRadius = radius
        if self.shadowRadius > 0 {
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowOffset = CGSize(width: 3, height: 3)
            self.layer.shadowRadius = self.shadowRadius
            self.layer.shadowOpacity = 0.5
        }

        self.clipsToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.refresh()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.refresh()
    }

}
