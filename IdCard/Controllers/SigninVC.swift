//
//  SigninVC.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/9/23.
//

import UIKit
import DTTextField
import JGProgressHUD


class SigninVC: UIViewController {
    
    @IBOutlet weak var showImg: UIImageView!
    @IBOutlet weak var emailTxt: DTTextField!
    @IBOutlet weak var passTxt: DTTextField!
    @IBOutlet weak var emailErr: UILabel!
    @IBOutlet weak var passErr: UILabel!
    
    var showPass : Bool = false
    var hud : JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTxt.addTarget(self, action: #selector(self.textEmailDidChange(_:)),
                                  for: .editingChanged)
        passTxt.addTarget(self, action: #selector(self.textPassDidChange(_:)),
                                  for: .editingChanged)
        emailTxt.placeholderColor = .gray
        emailTxt.borderColor = UIColor(rgb: 0x6D8EB5)
        emailTxt.floatPlaceholderColor = UIColor(rgb: 0x6D8EB5)
        emailTxt.floatPlaceholderActiveColor = UIColor(rgb: 0x6D8EB5)
        passTxt.placeholderColor = .gray
        passTxt.borderColor = UIColor(rgb: 0x6D8EB5)
        passTxt.floatPlaceholderColor = UIColor(rgb: 0x6D8EB5)
        passTxt.floatPlaceholderActiveColor = UIColor(rgb: 0x6D8EB5)
        
        hud = JGProgressHUD()
        hud.textLabel.text = "Waiting ..."
        
        preLogin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initLayout()
    }
    
    @IBAction func onSignin(_ sender: Any) {
        if validation() {
            loginHandle(emailTxt.text!, passTxt.text!)
        }
    }
    
    @IBAction func onForgot(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ForgotVC") as! ForgotVC
                self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onShowPass(_ sender: Any) {
        showPass = !showPass
        passTxt.isSecureTextEntry = !showPass
        setPassIcon()
    }
    
    func preLogin() {
        let email = getUserEmail()
        let pass = getUserPassword()
        if !email.isEmpty && !pass.isEmpty {
            loginHandle(email, pass)
        }
    }
    
    func loginHandle(_ email: String, _ password: String) {
        hud.show(in: self.view)
        API.login(email: email, password: password, onSuccess: { response in
            self.hud.dismiss()
            curUser = response
            setUserEmail(curUser.email)
            setUserPassword(curUser.password)
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(vc, animated: true)
        }, onFailed: { err in
            self.hud.dismiss()
            self.showToast(message:err)
        })
    }
    
    func validation() -> Bool {
        if emailTxt.text!.count == 0 {
            emailErr.text = "Email is required"
            return false
        }
        
        if !Utils.isValidEmail(emailTxt.text!) {
            emailErr.text = "Invalid Email"
            return false
        }
        
        if passTxt.text!.count == 0 {
            passErr.text = "Password is required"
            return false
        }
        
        if passTxt.text!.count < 6 {
            passErr.text = "Password must be longer than 6 characters"
            return false
        }
        
        return true
    }
    
    func setPassIcon(){
        if showPass {
            showImg.image = UIImage(named: "ic_pass_hide")
        } else {
            showImg.image = UIImage(named: "ic_pass_show")
        }
    }
    
    func initLayout() {
        showPass = false
        setPassIcon()
        emailErr.text = ""
        passErr.text = ""
        emailTxt.text = ""
        passTxt.text = ""
    }
    
    @objc func textEmailDidChange(_ textField: UITextField) {
        if !Utils.isValidEmail(textField.text!) {
            emailErr.text = "Invalid Email. Please type your email correctly."
        } else {
            emailErr.text = ""
        }
    }
    
    @objc func textPassDidChange(_ textField: UITextField) {
        if textField.text!.count == 0 {
            passErr.text = "Password is required"
        } else {
            passErr.text = ""
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
