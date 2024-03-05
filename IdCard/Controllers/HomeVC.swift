//
//  HomeVC.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/8/23.
//

import UIKit
import CoreNFC

class HomeVC: UIViewController {
    
    @IBOutlet weak var nfcImg: UIImageView!
    @IBOutlet weak var scanImg: UIImageView!
    @IBOutlet weak var orderImg: UIImageView!
    @IBOutlet weak var searchImg: UIImageView!
    @IBOutlet weak var settingImg: UIImageView!
    
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var nfcView: UIView!
    @IBOutlet weak var scanViewLeftConst: NSLayoutConstraint!
    @IBOutlet weak var orderViewRightConst: NSLayoutConstraint!
    @IBOutlet weak var searchViewLeftConst: NSLayoutConstraint!
    @IBOutlet weak var settingsViewCenterConst: NSLayoutConstraint!
    
    var permissions: [String:Bool]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        permissions = Utils.convertStringToDictionary(text: curUser.user_permissions) as? [String:Bool]
        
    }
    
    func initLayout() {
        scanImg.dropShadow()
        nfcImg.dropShadow()
        orderImg.dropShadow()
        searchImg.dropShadow()
        settingImg.dropShadow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initLayout()
        let bNFCReadable = NFCReaderSession.readingAvailable
        if !bNFCReadable {
            self.showToast(message: "This device does not supports the feature to scan the NFC tags.")
            self.nfcView.isHidden = true
        } else {
            self.nfcView.isHidden = false
        }
        refreshLayout(bNFCReadable)
    }
    
    @IBAction func onScanClick(_ sender: Any) {
        if permissions["cards_read"] != nil && permissions["cards_read"] == true {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ScanVC") as! ScanVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showToast(message: "You need the permission to read the cards")
        }
    }
        
    @IBAction func onNFCClick(_ sender: Any) {
        if permissions["cards_read"] != nil && permissions["cards_read"] == true {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "NfcVC") as! NfcVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showToast(message: "You need the permission to read the cards")
        }
    }
    
    @IBAction func onOrderClick(_ sender: Any) {
        if permissions["cards_order"] != nil && permissions["cards_order"] == true {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChooseProgramVC") as! ChooseProgramVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showToast(message: "You need the permission to order the cards")
        }
    }
    
    @IBAction func onSearchClick(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onSettingsClick(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshLayout(_ bNFC: Bool) {
        let width = self.view.frame.width
        if !bNFC {
            scanViewLeftConst.constant = width / 7
            orderViewRightConst.constant = width / 7
            searchViewLeftConst.constant = width / 7
            settingsViewCenterConst.constant = width * 3 / 14
        } else {
            settingsViewCenterConst.constant = 0
            scanViewLeftConst.constant = 24
            orderViewRightConst.constant = 24
            searchViewLeftConst.constant = 24
        }
        btnView.layoutIfNeeded()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
