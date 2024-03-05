//
//  LicenseVC.swift
//  IdCard
//
//  Created by XiangHao on 1/3/24.
//

import UIKit
import DTTextField

class LicenseVC: UIViewController {
    
    @IBOutlet weak var keyTxt: DTTextField!
    @IBOutlet weak var keyErr: UILabel!
    @IBOutlet weak var lbUuid: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        keyTxt.addTarget(self, action: #selector(self.textKeyDidChange(_:)),
                                  for: .editingChanged)
        keyTxt.placeholderColor = .gray
        keyTxt.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let key = getLibLicense()
        keyTxt.text = key
        keyErr.text = ""
        lbUuid.text = "Unique ID: " + Utils.getUniqueID()
    }
    
    @IBAction func onClickRegister(_ sender: Any) {
        if keyTxt.text!.count == 0 {
            keyErr.text = "License is required."
            return
        }
        setLibLicense(keyTxt.text!)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textKeyDidChange(_ textField: UITextField) {
        keyErr.text = ""
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
