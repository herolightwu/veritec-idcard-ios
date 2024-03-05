//
//  SearchVC.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/11/23.
//

import UIKit
import JGProgressHUD
import DNMeterialTextField


class SearchVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtCardID: DNMeterialTextField!
    @IBOutlet weak var txtErr: UILabel!
    
    var hud: JGProgressHUD!
    var searchedCard: [String : Any] = [:]
    var selectedProg: Program!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtCardID.addTarget(self, action: #selector(self.cardIdDidChange(_:)),
                                  for: .editingChanged)
        hud = JGProgressHUD()
        hud.textLabel.text = "Waiting ..."
        
        txtCardID.delegate = self
//        txtCardID.borderColor = UIColor(rgb: 0xD9D9D9)
//        txtCardID.placeholderColor = .dark
//        txtCardID.floatPlaceholderColor = .dark
//        txtCardID.floatPlaceholderActiveColor = .black
//        txtCardID.textColor = .black
//        txtCardID.backgroundColor = UIColor(rgb: 0xD9D9D9)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtErr.text = ""
        txtCardID.text = ""
        txtCardID.becomeFirstResponder()
    }
    
    @IBAction func onDone(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        if txtCardID.text!.count > 0 {
            hud.show(in: self.view)
            API.getCardById(cId: txtCardID.text!, token: curUser.token, onSuccess: { response in
                self.hud.dismiss()
                self.txtCardID.text = ""
                self.searchedCard = response
                self.getProgram()
            }, onFailed: { error in
                self.hud.dismiss()
                self.showToast(message: error)
            })
        } else {
            txtErr.text = ""
        }
        
    }
    
    func getProgram() {
        let programId = searchedCard["program_id"] as! Int
        hud.show(in: self.view)
        API.getCardProgram(id: programId, token: curUser.token, onSuccess: { response in
            self.hud.dismiss()
            self.selectedProg = response
            self.gotoCardVC()
        }, onFailed: { err in
            self.hud.dismiss()
            self.showToast(message: err)
        })
    }
    
    @objc func cardIdDidChange(_ textField: UITextField) {
        if textField.text!.count == 0 {
            txtErr.text = "Please type card ID."
        } else {
            txtErr.text = ""
        }
    }
    
    func gotoCardVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CardVC") as! CardVC
        vc.title = "Search Card"
        vc.viewMode = VIEW_MODE_SEARCH
        vc.selCard = searchedCard
        vc.selectedProg = selectedProg
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK - UITextField Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        if textField == txtCardID {
            let allowedCharacters = CharacterSet(charactersIn:"+0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
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
