//
//  ChangePassVC.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/9/23.
//

import UIKit
import JGProgressHUD
import DTTextField

class ChangePassVC: UIViewController {

    @IBOutlet weak var curPassTxt: DTTextField!
    @IBOutlet weak var newPassTxt: DTTextField!
    @IBOutlet weak var confirmTxt: DTTextField!
    @IBOutlet weak var curPassErr: UILabel!
    @IBOutlet weak var newPassErr: UILabel!
    @IBOutlet weak var confirmErr: UILabel!
    
    var hud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        curPassTxt.addTarget(self, action: #selector(self.curPassDidChange(_:)),
                                  for: .editingChanged)
        newPassTxt.addTarget(self, action: #selector(self.newPassDidChange(_:)),
                                  for: .editingChanged)
        confirmTxt.addTarget(self, action: #selector(self.confirmDidChange(_:)),
                                  for: .editingChanged)
        curPassTxt.placeholderColor = .gray
        newPassTxt.placeholderColor = .gray
        confirmTxt.placeholderColor = .gray
        curPassTxt.backgroundColor = .clear
        newPassTxt.backgroundColor = .clear
        confirmTxt.backgroundColor = .clear
        hud = JGProgressHUD()
        hud.textLabel.text = "Waiting ..."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        curPassTxt.text = ""
        newPassTxt.text = ""
        confirmTxt.text = ""
        curPassErr.text = ""
        newPassErr.text = ""
        confirmErr.text = ""
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSave(_ sender: Any) {
        if validation() {
            hud.show(in: self.view)
            API.resetPassword(token: curUser.token, uid: String(curUser.user_id), new_pass: newPassTxt.text!, old_pass: curPassTxt.text!, email: curUser.email, onSuccess: { response in
                self.hud.dismiss()
                self.showToast(message: response)
                curUser.password = self.newPassTxt.text!
                setUserPassword(self.newPassTxt.text!)
                self.navigationController?.popViewController(animated: true)
            }, onFailed: { error in
                self.hud.dismiss()
                self.showToast(message: error)
            })
        }
    }
    
    func validation() -> Bool {
        if curPassTxt.text!.count == 0 {
            curPassErr.text = "Please type your password."
            return false
        }
        
        if curPassTxt.text! != curUser.password {
            curPassErr.text = "Invalid Password. Please type password correctly."
            return false
        }
        
        if newPassTxt.text!.count == 0 {
            newPassErr.text = "Please type new password."
            return false
        }
        
        if confirmTxt.text!.count == 0 {
            confirmErr.text = "Please type confirm password."
            return false
        }
        
        if newPassTxt.text! != confirmTxt.text! {
            confirmErr.text = "Please type confirm password correctly."
            return false
        }
        return true
    }
    
    @objc func curPassDidChange(_ textField: UITextField) {
        curPassErr.text = ""
    }
    
    @objc func newPassDidChange(_ textField: UITextField) {
        newPassErr.text = ""
    }
    
    @objc func confirmDidChange(_ textField: UITextField) {
        confirmErr.text = ""
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
