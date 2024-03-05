//
//  WriteVC.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/10/23.
//

import UIKit
import JGProgressHUD
import CoreNFC
import AVFoundation


class WriteVC: UIViewController {
        
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var holderImg: UIImageView!
    @IBOutlet weak var vcodeImg: UIImageView!
    @IBOutlet weak var scodeImg: UIImageView!
    @IBOutlet weak var holderName: UILabel!
    @IBOutlet weak var fieldView: UIView!
    
    var session: NFCNDEFReaderSession!
//    private var sessionConnect = NFCNDEFReaderSession.connect
    
    var selCard: [String : Any] = [String : Any]()
    var fields: [Field] = []
    var selectedProg: Program!
    var nfc_data:NFCNDEFMessage!
    var bMovableDisp = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateMovableFields()
        configureData()
        startWriteSession()
    }
    
    @IBAction func onCancel(_ sender: Any) {
        if session != nil {
            session.invalidate()
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onWrite(_ sender: Any) {
        startWriteSession()
    }
    
    func startWriteSession(){
        session = NFCNDEFReaderSession(delegate: self,
                                       queue: nil,
                                       invalidateAfterFirstRead: false)
        session.begin()
    }
    
    func configureData() {
        selCard.removeValue(forKey: "face_image")
        selCard.removeValue(forKey: "barcode")
        selCard.removeValue(forKey: "vcard")
        selCard.removeValue(forKey: "modified_date")
        selCard.removeValue(forKey: "created_date")
        selCard.removeValue(forKey: "modified_user")
        selCard.removeValue(forKey: "created_user")
        selCard.removeValue(forKey: "nfc_fields")
        selCard.removeValue(forKey: "first_name")
        selCard.removeValue(forKey: "last_name")
        
        let data = Utils.convertDictionaryToJSON(selCard)!
        let str_data = data.removeNewLines()
        let externalType = Data(NFC_EXTERNAL_TYPE.utf8)
        let nfcData = Data(str_data.utf8)
        let id = Data("0".utf8)

        // Record with actual data we care about
        let relayRecord = NFCNDEFPayload(format: .nfcExternal, type: externalType, identifier: id, payload: nfcData)
        // Complete NDEF message with both records
        nfc_data = NFCNDEFMessage(records: [relayRecord])
    }
    
    func configureLayout() {
        let codeFields = self.selCard["code_fields"] as! [String: Any]
        var f_name = ""
        if codeFields["first_name"] != nil {
            f_name = codeFields["first_name"] as! String
        }
        var l_name = ""
        if codeFields["last_name"] != nil {
            l_name = codeFields["last_name"] as! String
        }
        holderName.text = f_name + " " + l_name
        
        let webp_base64 = self.selCard["compressed_face_image"] as? String
        let face_base64 = self.selCard["face_image"] as? String
        
        if selectedProg.printed_size == "large" {
            self.holderImg.image = UIImage.sd_image(withWebPData: Data(base64Encoded: webp_base64!))
        } else {
            self.holderImg.image = face_base64!.toImage()
        }
        
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
    }
    
    func updateMovableFields() {
        var bName = false
        for i in 0 ..< fields.count {
            let each = fields[i]
            if each.side > DISP_CARD_NONE {
                if !bMovableDisp {
                    bMovableDisp = true
                    holderName.isHidden = true
                }
                let xx = each.xpos * Int(fieldView.frame.width) / CARD_SIZE_WIDTH
                let yy = each.ypos * Int(fieldView.frame.height) / CARD_SIZE_HEIGHT
                let label = UILabel(frame: CGRect(x: xx, y: yy, width: 200, height: 20))
                if each.name.contains("name") {
                    bName = true
                    label.text = holderName.text
                } else {
                    label.text = each.label + ": " + each.value
                }
                label.textColor = getLabelColor(each.color)
                label.textAlignment = .left
                label.font = label.font.withSize(CGFloat(each.size))
                if each.side == DISP_CARD_BACK {
                    self.fieldView.addSubview(label)
                }
            }
        }
        if !bName {
            holderName.isHidden = true
            let xx = 88 * Int(fieldView.frame.width) / CARD_SIZE_WIDTH
            let yy = 125 * Int(fieldView.frame.height) / CARD_SIZE_HEIGHT
            let label = UILabel(frame: CGRect(x: xx, y: yy, width: 200, height: 20))
            label.text = holderName.text
            label.textColor = .black
            label.textAlignment = .left
            label.font = label.font.withSize(14)
            self.fieldView.addSubview(label)
        }
        self.fieldView.layoutIfNeeded()
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

extension WriteVC: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Session did invalidate with error: \(error)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("Detected tags with \(messages.count) messages")
        // no use
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        // 1
        guard tags.count == 1 else {
            session.invalidate(errorMessage: "Cannot Write More Than One Tag in NFC")
            return
        }
        let currentTag = tags.first!
        
        // 2
        session.connect(to: currentTag) { error in
            
            guard error == nil else {
                session.invalidate(errorMessage: "cound not connect to NFC card")
                return
            }
            
            // 3
            currentTag.queryNDEFStatus { status, capacity, error in
                
                guard error == nil else {
                    session.invalidate(errorMessage: "Write error")
                    return
                }
                
                switch status {
                case .notSupported: session.invalidate(errorMessage: "")
                case .readOnly:     session.invalidate(errorMessage: "Read Only")
                case .readWrite:
                    currentTag.writeNDEF(self.nfc_data) { error in
                        if error != nil {
                            session.invalidate(errorMessage: "Fail to write nfc card")
                        } else {
                            session.alertMessage = "Successfully writtern"
                            session.invalidate()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                @unknown default:   session.invalidate(errorMessage: "unknown error")
                }
            }
        }
    }
}
