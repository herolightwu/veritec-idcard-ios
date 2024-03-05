//
//  OrderVC.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/11/23.
//

import UIKit
import DTTextField
import UIImageCropper
import JGProgressHUD
import Alamofire
import SDWebImage

class OrderVC: UIViewController {
    
    @IBOutlet weak var constraintFieldsHeight: NSLayoutConstraint!
    @IBOutlet weak var fieldsView: UIView!
    @IBOutlet weak var originImg: UIImageView!
    @IBOutlet weak var compressImg: UIImageView!
    
    var selectedProgram: Program!
    var fieldList: [Field]! = []
    var fieldTxts: [DTTextField]! = []
    private var bConfig: Bool = false
    
    var picker: UIImagePickerController!
    var cropper: UIImageCropper!
    var holderImage: UIImage!
    var webpStr: String = ""
    var unique_id: String = ""
    var server_fields = [String: Any]()
    var code_fields = [String: Any]()
    var hud: JGProgressHUD!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        picker = UIImagePickerController()
        cropper = UIImageCropper(cropRatio: 1)
        hud = JGProgressHUD()
        hud.textLabel.text = "Waiting ..."
        
        configureFields()
        self.fieldsView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !bConfig {
            layoutFields(self.fieldsView.frame)
            self.fieldsView.layoutIfNeeded()
            bConfig = true
        }
    }
    
    @IBAction func onDone(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onOrder(_ sender: Any) {
        if webpStr.count < 100 {
            self.showToast(message: "Please fill out required fields")
            return
        }
        if server_fields.count > 0 {
            server_fields.removeAll() }
        if code_fields.count > 0 {
            code_fields.removeAll()
        }
        
        self.hud.show(in: self.view)
        
        for field in fieldList {
            if field.name == "name" {
                continue
            }
            let txtField = fieldTxts.filter{ $0.placeholder!.contains(field.label) }.first
            field.value = (txtField?.text!.trimmingCharacters(in: .whitespacesAndNewlines))!
            if field.value.count == 0 && txtField!.placeholder != "Middle Name" && txtField!.placeholder != "Address 2" {
                txtField!.showError(message: field.label + " is required")
                self.hud.dismiss()
                return
            } else {
                if field.type == "number" && !field.value.isNumber {
                    txtField!.showError(message: "Type is wrong")
                    self.hud.dismiss()
                    return
                }
                
                if field.extend {
                    server_fields[field.name] = field.value
                } else {
                    code_fields[field.name] = field.value
                }
            }
        }
        unique_id = String(format:"%02X", Date().millisecondsSince1970) + String(format: "%02X", Int.random(in: 1 ..< Int.max))
        var body_str:String = ""
        if selectedProgram.jsonbarcode.count > 8 {
            body_str = String(selectedProgram.program_id) + "~" + unique_id
            let json_format = selectedProgram.jsonbarcode
            var bExt = false
            for i in 0 ..< json_format.count {
                bExt = false
                for j in 0 ..< fieldList.count {
                    let each = fieldList[j]
                    let field_label = json_format[String(i)] as! String
                    if field_label == each.label {
                        body_str = body_str + "~" + each.value
                        bExt = true
                    }
                }
                if !bExt {
                    body_str = body_str + "~";
                }
            }
            if selectedProgram.matrix_size < ENC_INCLUDE_WEBP {
                body_str = body_str + "~" + "~" + "1"
            } else {
                body_str = body_str + "~" + webpStr + "~" + "1"
            }
        } else {
            var body = [String: Any]()
            body["unique_id"] = unique_id
            body["code_fields"] = Utils.convertDictionaryToJSON(code_fields)
            body["server_fields"] = Utils.convertDictionaryToJSON(server_fields)
            if (selectedProgram.matrix_size < ENC_INCLUDE_WEBP){
                body["compressed_image"] = ""
            } else {
                body["compressed_image"] = webpStr
            }
            body["program_id"] = selectedProgram.program_id
            body["available"] = true
            body_str = Utils.convertDictionaryToJSON(body)!
        }
        encodeData(body_str)
    }
    
    func orderCard(_ encodedData: String) {
        self.hud.show(in: self.view)
        API.orderCard(user: curUser, uid: unique_id, face_image: holderImage.base64Encode()! , comp_image: webpStr, pid: selectedProgram.program_id, code_f: Utils.convertDictionaryToJSON(code_fields)!, server_f: Utils.convertDictionaryToJSON(server_fields)!, encoded: encodedData, onSuccess: { resp in
            self.hud.dismiss()
            self.showChooseContinue()
        }, onFailed: { err in
            self.hud.dismiss()
            self.showToast(message: err)
        })
    }
    
    func encodeData(_ data:String) {
        let sData = data.removeNewLines()
        let params:Parameters = [
            "message": sData,
            "matrixsize": selectedProgram.matrix_size,
            "compression": selectedProgram.compression,
            "edac": selectedProgram.edac
        ]
        
        API.encodeData(token: curUser.token, body: params, onSuccess: { resp in
            self.hud.dismiss()
            self.orderCard(resp)
        }, onFailed: { err in
            self.hud.dismiss()
            self.showToast(message: err)
        })
    }
    
    func showChooseContinue() {
        let alert = UIAlertController(title: "", message: "Your card has been ordered. Continue order?", preferredStyle: .actionSheet)
        let doneAction = UIAlertAction(title: "Continue", style: .default, handler: { (action) in
            self.initFields()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
        
    @IBAction func onChoosePhoto(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Photo", message: "", preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Choose from Library", style: .default, handler: { (action) in
            self.showImagePickerController(.photoLibrary)
        })
        let cameraAction = UIAlertAction(title: "Take from Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.showImagePickerController(.camera)
            } else {
                self.showToast(message: "Camera is not available")
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func initFields() {
        holderImage = nil
        webpStr = ""
        for i in 1 ..< fieldList.count {
            fieldList[i].value = ""
            fieldTxts[i].text = ""
            fieldTxts[i].hideError()
        }
        originImg.image = nil
        compressImg.image = nil
    }
    
    func convertImageToWebp() {
        let webpData = Utils.convertPngToWebp(holderImage)
        if webpData != nil {
            webpStr = (webpData?.base64EncodedString())! 
            originImg.image = holderImage
            compressImg.image = UIImage.sd_image(withWebPData: Data(base64Encoded: webpStr))
        } else {
            self.showToast(message: "Image compress failed")
        }
    }
    
    func showImagePickerController(_ srcType: UIImagePickerController.SourceType) {
        picker.sourceType = srcType
        cropper.picker = picker
        cropper.delegate = self
        cropper.cropButtonText = "Crop" // button labes can be localised/changed
        cropper.cancelButtonText = "Cancel"
        self.present(self.picker, animated: true, completion: nil)
    }
    
    func layoutFields(_ frame: CGRect) {
        var yy = 16
        for item in fieldList {
            let fTxt = DTTextField(frame: CGRect(x: 16, y: yy, width: Int(frame.width) - 32, height: 48))
            initializeTextField(fTxt, item)
            
            if item.label == "Middle Name" || item.label == "Address 2" {
                fTxt.placeholder = item.label
            } else {
                fTxt.placeholder = item.label + " *"
            }
            if item.value.count > 0 {
                fTxt.text = item.value
            }
            fTxt.font = fTxt.font?.withSize(14)
            fTxt.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                            for: .editingChanged)
            fieldsView.addSubview(fTxt)
            fieldTxts.append(fTxt)
            yy = yy + 60
        }
        
        constraintFieldsHeight.constant = CGFloat(yy + 160)
    }
    
    @objc func textFieldDidChange(_ textField: DTTextField) {
        if textField.text!.count == 0 {
            if textField.placeholder! != "Middle Name" && textField.placeholder! != "Address 2" {
                textField.showError(message: textField.placeholder! + " is required.")
            }
        } else {
            if textField.placeholder == "Email" || textField.placeholder == "email" {
                if !Utils.isValidEmail(textField.text!) {
                    textField.showError(message: "Invaild email format")
                } else {
                    textField.hideError()
                }
            } else {
                textField.hideError()
            }
        }
    }
    
    func initializeTextField(_ txtField: DTTextField, _ field: Field) {
        txtField.borderColor = UIColor(rgb: 0x6D8EB5)
        txtField.placeholderColor = UIColor(rgb: 0x6D8EB5)
        txtField.floatPlaceholderColor = UIColor(rgb: 0x6D8EB5)
        txtField.floatPlaceholderActiveColor = UIColor(rgb: 0x6D8EB5)
        
        if field.name == "card_program" {
            txtField.isUserInteractionEnabled = false
            txtField.textColor = .gray
        } else {
            txtField.textColor = .black
        }
        if field.type == "number" {
            txtField.keyboardType = .numberPad
        } else if field.name == "email" {
            txtField.keyboardType = .emailAddress
        } else if field.name == "phone" {
            txtField.keyboardType = .phonePad
        } else {
            txtField.keyboardType = .default
        }
        
    }
    
    func configureFields() {
        let f0 = Field()
        f0.label = "Card Program"
        f0.placeholder = "Card Program Name"
        f0.type = "text"
        f0.name = "card_program"
        f0.value = selectedProgram.program_name
        self.fieldList.append(f0)
        
        for item in selectedProgram.program_template {
            let ff = Field(dictionary: item)
            ff.name = ff.label.lowercased().replacingOccurrences(of: " ", with: "_")
            self.fieldList.append(ff)
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

extension OrderVC: UIImageCropperProtocol {
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        holderImage = croppedImage?.resizeImage(newWidth: 80)
        self.convertImageToWebp()
    }
    
    //optional (if not implemented cropper will close itself and picker)
    func didCancel() {
        picker.dismiss(animated: true, completion: nil)
    }
}
