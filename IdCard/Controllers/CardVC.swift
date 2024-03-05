//
//  CardVC.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/10/23.
//

import UIKit
import JGProgressHUD
import DTTextField
import UIImageCropper
import Alamofire
import CoreNFC


class CardVC: UIViewController {
    
    var mTitle: String! = "Optical Scan"
    
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var btnData: UIButton!
    @IBOutlet weak var btnCard: UIButton!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var actDataV: UIView!
    @IBOutlet weak var actCardV: UIView!
    @IBOutlet weak var actImageV: UIView!
    @IBOutlet weak var btnNfc: UIButton!
    
    @IBOutlet weak var viewEditBtn: RoundShadowView!
    
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var holderImg: UIImageView!
    
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var frontImg: UIImageView!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var holderImg2: UIImageView!
    @IBOutlet weak var vcodeImg: UIImageView!
    @IBOutlet weak var scodeImg: UIImageView!
    
    @IBOutlet weak var cardBackLayout: UIView!
    @IBOutlet weak var cardFrontLayout: UIView!
    @IBOutlet weak var holdername: UILabel!
    @IBOutlet weak var holderid: UILabel!
    
    @IBOutlet weak var viewData: UIView!
    
    @IBOutlet weak var fieldsLayout: UIView!
    @IBOutlet weak var constrainLayoutHeight: NSLayoutConstraint!
    @IBOutlet weak var btnChangePhoto: UIButton!
    
    private var nTab: Int! = 0   //0- data, 1 - image, 2 - card
    private var bEditable: Bool! = false
    private var bMovableDisp: Bool = false
    var selCard: [String : Any] = [String : Any]()
    var selectedProg: Program!
    var viewMode: Int = VIEW_MODE_SCAN
    var fields: [Field] = []
    var fieldTxts: [DTTextField] = []
    var webp_base64: String!
    var face_base64: String!
    var memberId: String!
    
    private var bConfig: Bool = false
    private var bFieldChanged: Bool = false
    private var bImageChanged: Bool = false
    var picker: UIImagePickerController!
    var cropper: UIImageCropper!
    var newImage: UIImage!
    var webpStr: String = ""
    
    var hud: JGProgressHUD!
    var permissions: [String:Bool]!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        hud = JGProgressHUD()
        hud.textLabel.text = "Waiting ..."
        // Do any additional setup after loading the view.
        permissions = Utils.convertStringToDictionary(text: curUser.user_permissions) as? [String:Bool]
        
        holderid.text = ""
        holdername.text = ""
        holderid.isHidden = false
        holdername.isHidden = false
        btnChangePhoto.isHidden = true
        
        setCardFields()
        configFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initLayout()
        if !bConfig {
            configureLayout(self.view.frame)
            fieldsLayout.layoutIfNeeded()
            bConfig = true
        }
        refreshLayout()
    }
    
    func initLayout() {
        titleLb.text = title
        bEditable = false
        if NFCReaderSession.readingAvailable {
            btnNfc.isHidden = false
        } else {
            btnNfc.isHidden = true
            self.showToast(message: "This device does not supports the feature to scan the NFC tags.")
        }
        
        if permissions["nfc_write"] != nil && permissions["nfc_write"] == true {
            btnNfc.isHidden = false
        } else { // permission denied
            btnNfc.isHidden = true
        }
    }
    
    func refreshLayout() {
        switch nTab {
        case 1:
            actDataV.isHidden = true
            actImageV.isHidden = false
            actCardV.isHidden = true
            btnData.titleLabel?.textColor = UIColor(rgb: 0xD9D9D9)
            btnImage.titleLabel?.textColor = UIColor.white
            btnCard.titleLabel?.textColor = UIColor(rgb: 0xD9D9D9)
            
            viewData.isHidden = true
            viewImg.isHidden = false
            viewCard.isHidden = true
            break
        case 2: //Card Tab
            actDataV.isHidden = true
            actImageV.isHidden = true
            actCardV.isHidden = false
            btnData.titleLabel?.textColor = UIColor(rgb: 0xD9D9D9)
            btnImage.titleLabel?.textColor = UIColor(rgb: 0xD9D9D9)
            btnCard.titleLabel?.textColor = UIColor.white
            viewData.isHidden = true
            viewImg.isHidden = true
            viewCard.isHidden = false
            if !bMovableDisp {
                updateMovableFields()
            }
            break
        default:
            actDataV.isHidden = false
            actImageV.isHidden = true
            actCardV.isHidden = true
            btnData.titleLabel?.textColor = UIColor.white
            btnImage.titleLabel?.textColor = UIColor(rgb: 0xD9D9D9)
            btnCard.titleLabel?.textColor = UIColor(rgb: 0xD9D9D9)
            viewData.isHidden = false
            viewImg.isHidden = true
            viewCard.isHidden = true
        }
    }
    
    @IBAction func onDataTab(_ sender: Any) {
        nTab = 0
        refreshLayout()
    }
    
    @IBAction func onCardTab(_ sender: Any) {
        nTab = 2
        refreshLayout()
    }
    
    @IBAction func onImageTab(_ sender: Any) {
        nTab = 1
        refreshLayout()
    }
    
    @IBAction func onClickChangePhoto(_ sender: Any) {
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
    
    @IBAction func onEdit(_ sender: Any) {
        bEditable = !bEditable
        changeEditable()
    }
    
    @IBAction func onDone(_ sender: Any) {
        if bEditable {
            if bFieldChanged {
                for item in fields {
                    let txtField = fieldTxts.filter{ $0.placeholder == item.label }.first
                    if item.label != "Card Program" && item.label != "Card ID" && item.label != "Card Status" {
                        txtField?.text = item.value
                    }
                }
                bFieldChanged = false
            }
            if bImageChanged {
                if selectedProg.printed_size == "large" {
                    self.holderImg.image = UIImage.sd_image(withWebPData: Data(base64Encoded: webp_base64))
                    self.holderImg2.image = UIImage.sd_image(withWebPData: Data(base64Encoded: webp_base64))
                } else {
                    self.holderImg.image = face_base64.toImage()
                    self.holderImg2.image = face_base64.toImage()
                }
                bImageChanged = false
            }
            
            bEditable = !bEditable
            changeEditable()
        } else {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: HomeVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
    
    @IBAction func onNext(_ sender: Any) {
        if bEditable { //Save
            if bFieldChanged || bImageChanged {
                encodeCardData()
            } else {
                bEditable = !bEditable
                changeEditable()
            }
            
        } else {    //Next
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onNfcWrite(_ sender: Any) {
        hud.show(in: self.view)
        let cId = self.selCard["card_id"] as! Int
        API.getCardById(cId: String(cId), token: curUser.token, onSuccess: { response in
            self.hud.dismiss()
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WriteVC") as! WriteVC
            vc.selectedProg = self.selectedProg
            vc.selCard = response
            vc.fields = self.fields
            self.navigationController?.pushViewController(vc, animated: true)
        }, onFailed: { error in
            self.hud.dismiss()
            self.showToast(message: error)
        })
    }
    
    func encodeCardData() {
        self.hud.show(in: self.view)
        var server_fields = [String: Any]()
        var code_fields = [String: Any]()
        for item in fields {
            if item.label == "Card ID" { continue }
            let txtField = fieldTxts.filter{ $0.placeholder == item.label }.first
            var newVal = item.value
            if txtField != nil {
                newVal = (txtField?.text!.trimmingCharacters(in: .whitespacesAndNewlines))!
            }
            
            if newVal.count == 0 && item.placeholder != "Middle Name" && item.placeholder != "Address 2" {
                txtField?.showError(message: item.label + " is required.")
                self.hud.dismiss()
                return
            } else {
                if item.type == "number" && !newVal.isNumber {
                    txtField?.showError(message: "Type is wrong.")
                    self.hud.dismiss()
                    return
                }
                if item.extend {
                    server_fields[item.name] = newVal
                } else {
                    code_fields[item.name] = newVal
                }
            }
        }
        
        var body_str:String = ""
        if selectedProg.jsonbarcode.count > 8 {
            let unique_id = selCard["unique_id"] as! String
            body_str = String(selectedProg.program_id) + "~" + unique_id
            let json_format = selectedProg.jsonbarcode
            var bExt = false
            for i in 0 ..< json_format.count {
                bExt = false
                for j in 0 ..< fields.count {
                    let each = fields[j]
                    let field_label = json_format[String(i)] as! String
                    let txtField = fieldTxts.filter{ $0.placeholder == each.label }.first
                    var newVal = each.value
                    if txtField != nil {
                        newVal = (txtField?.text!.trimmingCharacters(in: .whitespacesAndNewlines))!
                    }
                    
                    if field_label == each.label {
                        body_str = body_str + "~" + newVal
                        bExt = true
                    }
                }
                if !bExt {
                    body_str = body_str + "~";
                }
            }
            if selectedProg.matrix_size < ENC_INCLUDE_WEBP {
                body_str = body_str + "~" + "~" + "1"
            } else {
                body_str = body_str + "~" + webpStr + "~" + "1"
            }
        } else {
            var body = [String: Any]()
            body["unique_id"] = selCard["unique_id"]
            body["code_fields"] = Utils.convertDictionaryToJSON(code_fields)
            body["server_fields"] = Utils.convertDictionaryToJSON(server_fields)
            if (selectedProg.matrix_size < ENC_INCLUDE_WEBP){
                body["compressed_image"] = ""
            } else {
                if bImageChanged {
                    body["compressed_image"] = webpStr
                } else {
                    body["compressed_image"] = webp_base64
                }
            }
            body["program_id"] = selectedProg.program_id
            body["available"] = true
            body_str = Utils.convertDictionaryToJSON(body)!
        }
        
        let sData = body_str.removeNewLines()
        let params:Parameters = [
            "message": sData,
            "matrixsize": selectedProg.matrix_size,
            "compression": selectedProg.compression,
            "edac": selectedProg.edac
        ]
        
        API.encodeData(token: curUser.token, body: params, onSuccess: { resp in
            self.hud.dismiss()
            self.updateCard(resp, code_fields, server_fields)
        }, onFailed: { err in
            self.hud.dismiss()
            self.showToast(message: err)
        })
    }
    
    func updateCard(_ encoded: String,_ codeFields: [String: Any],_ serverFields: [String: Any]) {
        self.hud.show(in: self.view)
        let cId = self.selCard["card_id"] as! String
        API.editCard(user: curUser, cid: cId, face_image: newImage.base64Encode()!, comp_image: webpStr, code_f: Utils.convertDictionaryToJSON(codeFields)!, server_f: Utils.convertDictionaryToJSON(serverFields)!, encoded: encoded, onSuccess: { response in
            self.hud.dismiss()
            self.bEditable = !self.bEditable
            self.bFieldChanged = false
            self.bImageChanged = false
            self.changeEditable()
            for item in self.fields {
                let txtField = self.fieldTxts.filter{ $0.placeholder == item.label }.first
                if item.label != "Card Program" && item.label != "Card ID" && item.label != "Card Status" {
                    item.value = (txtField?.text!.trimmingCharacters(in: .whitespacesAndNewlines))!
                }
            }
            
        }, onFailed: { err in
            self.hud.dismiss()
            self.showToast(message: err)
        })
        
    }
    
    func showImagePickerController(_ srcType: UIImagePickerController.SourceType) {
        picker.sourceType = srcType
        cropper.picker = picker
        cropper.delegate = self
        cropper.cropButtonText = "Crop" // button labes can be localised/changed
        cropper.cancelButtonText = "Cancel"
        self.present(self.picker, animated: true, completion: nil)
    }
    
    func changeEditable() {
        viewEditBtn.isHidden = bEditable
        if bEditable {
            btnDone.titleLabel?.text = "CANCEL"
            btnNext.titleLabel?.text = "SAVE"
            btnChangePhoto.isHidden = false
        } else {
            btnDone.titleLabel?.text = "DONE"
            btnNext.titleLabel?.text = "NEXT"
            btnChangePhoto.isHidden = true
        }
        for txt in fieldTxts {
            if txt.placeholder != "Card Program" && txt.placeholder != "Card ID" && txt.placeholder != "Card Status" {
                txt.isUserInteractionEnabled = bEditable
                if bEditable {
                    txt.textColor = .black
                } else {
                    txt.textColor = .gray
                }
                txt.hideError()
            }
        }
        fieldsLayout.layoutIfNeeded()
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
        bFieldChanged = true
    }
    
    func configFields(){
        hud.show(in: self.view)
        
        var f_name = ""
        var l_name = ""
        fields[0].value = self.selectedProg.program_name
        let codeFields = self.selCard["code_fields"] as! [String: Any]
        let serverFields = self.selCard["server_fields"] as! [String: Any]
        let count = fields.count
        for i in 1...count-1 {
            if selCard.keys.contains(fields[i].name) {
                if let val = selCard[fields[i].name] as? String {
                    fields[i].value = val
                } else {
                    if let vv = selCard[fields[i].name] as? Int {
                        fields[i].value = String(vv)
                    } else {
                        fields[i].value = ""
                    }
                }
            } 
            if codeFields.keys.contains(fields[i].name) {
                if let val = codeFields[fields[i].name] as? String {
                    fields[i].value = val
                } else {
                    if let vv = codeFields[fields[i].name] as? Int {
                        fields[i].value = String(vv)
                    } else {
                        fields[i].value = ""
                    }
                }
            } else if serverFields.keys.contains(fields[i].name) {
                if let val = serverFields[fields[i].name] as? String {
                    fields[i].value = val
                } else {
                    if let vv = serverFields[fields[i].name] as? Int {
                        fields[i].value = String(vv)
                    } else {
                        fields[i].value = ""
                    }
                }
            }
            
            if fields[i].name == "member_id" || fields[i].name == "card_id" {
                memberId = fields[i].value
            }
            
            if fields[i].name == "first_name" {
                f_name = fields[i].value
            }
            if fields[i].name == "last_name" {
                l_name = fields[i].value
            }
        }
        
        holdername.text = f_name + " " + l_name
        holderid.text = "ID: " + memberId
        
        webp_base64 = self.selCard["compressed_face_image"] as? String
        face_base64 = self.selCard["face_image"] as? String
        
        if selectedProg.printed_size == "large" {
            self.holderImg.image = UIImage.sd_image(withWebPData: Data(base64Encoded: webp_base64))
            self.holderImg2.image = UIImage.sd_image(withWebPData: Data(base64Encoded: webp_base64))
        } else {
            self.holderImg.image = face_base64.toImage()
            self.holderImg2.image = face_base64.toImage()
        }
        
        frontImg.image = self.selectedProg.card_image_front.toImage()
        backImg.image = self.selectedProg.card_image_back.toImage()
        // display vericode
        DispatchQueue.main.async {
            if self.selCard.keys.contains("barcode") {
                if let codeImage = Utils.convertCodeToBmp(from: self.selCard["barcode"] as! String) {
                    if self.selectedProg.printed_size == "large" {
                        self.vcodeImg.isHidden = false
                        self.scodeImg.isHidden = true
                        self.vcodeImg.image = codeImage
                    } else {
                        self.vcodeImg.isHidden = true
                        self.scodeImg.isHidden = false
                        self.scodeImg.image = codeImage
                    }
                } else {
                    self.vcodeImg.isHidden = true
                    self.scodeImg.isHidden = true
                }
            } else {
                self.vcodeImg.isHidden = true
                self.scodeImg.isHidden = true
            }
        }
        
        hud.dismiss()
    }
    
    func configureLayout(_ frame: CGRect) {
        var yy = 16
        for item in fields {
            if item.name == "name" {
                continue
            }
            let fTxt = DTTextField(frame: CGRect(x: 16, y: yy, width: Int(frame.width) - 32, height: 48))
            initializeTextField(fTxt, item)
            fTxt.placeholder = item.label
            if item.value.count > 0 {
                fTxt.text = item.value
            }
            fTxt.font = fTxt.font?.withSize(14)
            fTxt.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                            for: .editingChanged)
            fieldsLayout.addSubview(fTxt)
            fieldTxts.append(fTxt)
            yy = yy + 60
        }
        if constrainLayoutHeight.constant < CGFloat(yy) {
            constrainLayoutHeight.constant = CGFloat(yy)
        }
    }
    
    func initializeTextField(_ txtField: DTTextField, _ field: Field) {
        txtField.borderColor = UIColor(rgb: 0x6D8EB5)
        txtField.placeholderColor = UIColor(rgb: 0x6D8EB5)
        txtField.floatPlaceholderColor = UIColor(rgb: 0x6D8EB5)
        txtField.floatPlaceholderActiveColor = UIColor(rgb: 0x6D8EB5)
        txtField.isUserInteractionEnabled = false
        txtField.textColor = .gray
                
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
    
    func setCardFields() {
        setDefaultFields()
        for item in selectedProg.program_template {
            let ff = Field(dictionary: item)
            ff.name = ff.label.lowercased().replacingOccurrences(of: " ", with: "_")
            self.fields.append(ff)
        }
    }
    
    func getTemplateField (_ fLabel: String) -> Field? {
        for tmp in selectedProg.program_template {
            let retTemp = Field(dictionary: tmp)
            if retTemp.label == fLabel {
                return retTemp
            }
        }
        return nil
    }    
    
    func updateMovableFields() {
        var bName = false
        for i in 0 ..< fields.count {
            let each = fields[i]
            if each.side > DISP_CARD_NONE {
                if !bMovableDisp {
                    bMovableDisp = true
                    holderid.isHidden = true
                    holdername.isHidden = true
                }
                let xx = each.xpos * Int(cardFrontLayout.frame.width) / CARD_SIZE_WIDTH
                let yy = each.ypos * Int(cardFrontLayout.frame.height) / CARD_SIZE_HEIGHT
                let label = UILabel(frame: CGRect(x: xx, y: yy, width: 200, height: 20))
                if each.name.contains("name") {
                    bName = true
                    label.text = holdername.text
                } else {
                    label.text = each.label + ": " + each.value
                }
                label.textColor = getLabelColor(each.color)
                label.textAlignment = .left
                label.font = label.font.withSize(CGFloat(each.size))
                if each.side == DISP_CARD_FRONT {
                    self.cardFrontLayout.addSubview(label)
                } else {
                    self.cardBackLayout.addSubview(label)
                }
            }
        }
        if !bName {
            holdername.isHidden = true
            let xx = 88 * Int(cardFrontLayout.frame.width) / CARD_SIZE_WIDTH
            let yy = 125 * Int(cardFrontLayout.frame.height) / CARD_SIZE_HEIGHT
            let label = UILabel(frame: CGRect(x: xx, y: yy, width: 200, height: 20))
            label.text = holdername.text
            label.textColor = .black
            label.textAlignment = .left
            label.font = label.font.withSize(14)
            self.cardBackLayout.addSubview(label)
        }
        self.cardFrontLayout.layoutIfNeeded()
        self.cardBackLayout.layoutIfNeeded()
    }
    
    func setDefaultFields(){
        let field0 = Field()
        field0.label = "Card Program"
        field0.placeholder = "Card Program Name"
        field0.type = "text"
        field0.name = "card_program"
        field0.value = "Unknown Program"
        fields.append(field0)

        let field1 = Field()
        field1.label = "Card ID"
        field1.placeholder = "Card ID Number"
        field1.type = "text"
        field1.name = "card_id"
        field1.value = ""
        fields.append(field1)

        let field2 = Field()
        field2.label = "Card Status"
        field2.placeholder = "Status"
        field2.type = "text"
        field2.name = "card_status"
        field2.value = "available"
        fields.append(field2)
    }
    
    func convertImageToWebp() {
        let webpData = Utils.convertPngToWebp(newImage)
        if webpData != nil {
            bImageChanged = true
            webpStr = (webpData?.base64EncodedString())!
            holderImg.image = newImage
            holderImg2.image = UIImage.sd_image(withWebPData: Data(base64Encoded: webpStr))
        } else {
            self.showToast(message: "Image compress failed")
        }
    }
}

extension CardVC: UIImageCropperProtocol {
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        newImage = croppedImage?.resizeImage(newWidth: 80)
        self.convertImageToWebp()
    }
    
    //optional (if not implemented cropper will close itself and picker)
    func didCancel() {
        picker.dismiss(animated: true, completion: nil)
    }
}
