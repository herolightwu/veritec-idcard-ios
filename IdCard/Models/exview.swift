//
//  exview.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/8/23.
//

import UIKit


extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 3
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UIViewController {
    @objc func actionBack(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if self.navigationController != nil {
                self.navigationController!.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: completion)
            }
        }
    }
    
    func showToast(message: String) {
        self.view.makeToast(message)
    }
}

