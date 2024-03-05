//
//  NfcVC.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/10/23.
//

import UIKit
import CoreNFC
import JGProgressHUD
import AVFoundation


class NfcVC: UIViewController {
    
    var session: NFCNDEFReaderSession!
    var hud: JGProgressHUD!
    
    var searchedCard: [String:Any] = [String:Any]()
    var selectedProg: Program!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hud = JGProgressHUD()
        hud.textLabel.text = "Waiting ..."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanCard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if session != nil {
            session.invalidate()
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        if session != nil {
            session.invalidate()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func decryptData(_ inData: String) {
        let recData = Utils.convertStringToDictionary(text: inData)
        let uid = recData!["unique_id"] as! String
        self.hud.show(in: self.view)
        API.getCardByUid(unique_id: uid, token: curUser.token, onSuccess: { response in
            self.searchedCard = response
            self.getProgram(recData!)
        }, onFailed: { err in
            self.hud.dismiss()
            self.showToast(message: err)
            self.scanCard()
        })
        uploadScanInfo(inData)
    }
    
    func getProgram(_ nfcData: [String:Any]) {
        let programId = nfcData["program_id"] as! Int
        API.getCardProgram(id: programId, token: curUser.token, onSuccess: { resp in
            self.hud.dismiss()
            self.selectedProg = resp
            self.gotoCardView()
        }, onFailed: { error in
            self.hud.dismiss()
            self.showToast(message: error)
            self.scanCard()
        })
    }
    
    func gotoCardView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CardVC") as! CardVC
        vc.title = "NFC Scan"
        vc.selCard = self.searchedCard
        vc.selectedProg = self.selectedProg
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func uploadScanInfo(_ scanInfo: String) {
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        API.scanCard(scan_data: scanInfo, scan_type: String(SCAN_TYPE_NFC), user_id: String(curUser.user_id), dev_id: uuid, token: curUser.token, onSuccess: { resp in
            self.showToast(message: "Scan Information upload success.")
        }, onFailed: { err in
            self.showToast(message: "Scan Information uploading failed.")
        })
    }
    
    @IBAction func onRescan(_ sender: Any) {
        if session != nil {
            session.begin()
        }
    }
    
    func scanCard() {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.begin()
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

extension NfcVC: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Session did invalidate with error: \(error)")
//        DispatchQueue.main.async {
//            self.showToast(message: "Session did invalidate with error: \(error) \nPlease try to scan the NFC tags again.")
//        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            var result: String = ""
            for msgIndex in 0 ..< messages.count {
                let msg = messages[msgIndex]
                
                for recordInd in 0 ..< msg.records.count {
                    let record = msg.records[recordInd]
                    let rec_type = String(data: record.type, encoding: .utf8)
                    if rec_type == NFC_EXTERNAL_TYPE {
                        let rec_str = String(data: record.payload, encoding: .ascii)
                        result = result + rec_str!
                    }
                }
            }
            
            if result.count > MIN_DATA_SIZE {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.decryptData(result)
            } else {
                self.showToast(message: "Invalid data. Please rescan NFC data")
            }
        }
    }
    
    
}
