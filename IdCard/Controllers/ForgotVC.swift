//
//  ForgotVC.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/9/23.
//

import UIKit
import DNMeterialTextField
import JGProgressHUD


class ForgotVC: UIViewController {
        
    @IBOutlet weak var emailErr: UILabel!
    @IBOutlet weak var emailTxt: DNMeterialTextField!
    
    var hud: JGProgressHUD!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTxt.addTarget(self, action: #selector(self.textEmailDidChange(_:)),
                                  for: .editingChanged)
        hud = JGProgressHUD()
        hud.textLabel.text = "Waiting ..."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailErr.text = ""
        emailTxt.text = ""
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        if Utils.isValidEmail(emailTxt.text!) {
            hud.show(in: self.view)
            API.forgotPassword(token: curUser.token, email: emailTxt.text!, onSuccess: { response in
                self.hud.dismiss()
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ResetVC") as! ResetVC
                self.navigationController?.pushViewController(vc, animated: true)
            }, onFailed: { err in
                self.hud.dismiss()
                self.showToast(message: err)
            })
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textEmailDidChange(_ textField: UITextField) {
        if textField.text!.count == 0 {
            emailErr.text = "Email is required."
            return
        }
        
        if !Utils.isValidEmail(textField.text!) {
            emailErr.text = "Invalid Email. Please type your email correctly."
        } else {
            emailErr.text = ""
        }
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
