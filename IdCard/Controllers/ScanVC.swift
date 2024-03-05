//
//  ScanVC.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/10/23.
//

import UIKit
import AVFoundation
import JGProgressHUD


class ScanVC: UIViewController {
    
    @IBOutlet weak var scanedImg: UIImageView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var overlayView: UIView!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    private let photoOutput = AVCapturePhotoOutput()
    private var isCapturing = false
    
    private var encodeImg: UIImage!
    
    var searchedCard: [String:Any] = [String:Any]()
    var selectedProg: Program!
    
    var hud: JGProgressHUD!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black
        hud = JGProgressHUD()
        hud.textLabel.text = "Waiting ..."
                
    }
    
    func captureVCode() {
        let photoSettings = AVCapturePhotoSettings()
        if !isCapturing {
            isCapturing = true
            self.hud.show(in: self.view)
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if captureSession != nil {
            if (captureSession?.isRunning == false) {
                captureSession.startRunning()
            }
        } else {
            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }

            if (captureSession.canAddInput(videoInput)) {
                captureSession.addInput(videoInput)
            } else {
                failed()
                return
            }
            captureSession.addOutput(photoOutput)

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = preview.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            preview.layer.addSublayer(previewLayer)

            captureSession.startRunning()
//            DispatchQueue.main.asyncAfter(deadline: .now()) {
//                self.captureSession.startRunning()
//            }
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickLicense(_ sender: Any) {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LicenseVC") as! LicenseVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickShutter(_ sender: Any) {
        self.captureVCode()
    }
    
    func failed() {
        self.showToast(message: "Your device does not support scanning a code from an item. Please use a device with a camera.")
        captureSession = nil
    }
    
    // BMP (Windows) Header Format
    // Windows BMP files begin with a 54-byte header:
    //      offset      size        description
    //      0           2           signature, must be 4D42 hex
    //      2           4           size of BMP file in bytes (unreliable)
    //      6           2           reserved, must be zero
    //      8           2           reserved, must be zero
    //      10          4           offset to start of image data in bytes
    //      14          4           size of BITMAPINFOHEADER structure, must be 40
    //      18          4           image width in pixels
    //      22          4           image height in pixels
    //      26          2           number of planes in the image, must be 1
    //      28          2           number of bits per pixel (1, 4, 8, or 24)
    //      30          4           compression type (0=none, 1=RLE-8, 2=RLE-4)
    //      34          4           size of image data in bytes (including padding)
    //      38          4           horizontal resolution in pixels per meter (unreliable)
    //      42          4           vertical resolution in pixels per meter (unreliable)
    //      46          4           number of colors in image, or zero
    //      50          4           number of important colors, or zero
    
    func decodeCardData() {
        // process encodeImg -> card data string
        let sWidth = Int(self.encodeImg.size.width)
        let sHeight = Int(self.encodeImg.size.height)
        print("Image size: \(sWidth) x \(sHeight)")
        let options: NSDictionary = [:]
        let convertToBmp = encodeImg.toData(options: options, type: .bmp)
        guard let bmpData = convertToBmp else {
            print("😡 ERROR: could not convert image to a bitmap bmpData var.")
            self.hud.dismiss()
            self.showToast(message: "Could not convert image to a bitmap. Please scan again.")
            return
        }
        
        guard let pbmp = bmpData.toPointer() else {
            print("😡 ERROR: could not convert bitmap bmpData to pointer.")
            self.hud.dismiss()
            self.showToast(message: "Could not get a bitmap pointer. Please scan again.")
            return
        }
//        print(pbmp[28])
        
        let decode_bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: 2 * 32268)
        let ach_pw_str = getLibLicense() //2AE5B1A2
        let ach_pw = ach_pw_str.toPointer()
        let ach_uid_str = Utils.getUniqueID()
        let ach_uid = ach_uid_str.toPointer()
        print(ach_pw_str)
        print(ach_uid_str)
//        if ach_pw_str == "DEMO" {
//            self.hud.dismiss()
//            self.showToast(message: "You need to register a license. Please get new licence.")
//            return
//        }
        // default setting
        g_vcOpt.SampleWidth = 4
        g_vcOpt.BitsPerCell = 4
        g_vcOpt.AorLeft = g_vcOpt.SampleWidth + 1
        g_vcOpt.AorRight = Int16(sWidth)-(g_vcOpt.SampleWidth+2)
        g_vcOpt.AorTop = g_vcOpt.SampleWidth+1
        g_vcOpt.AorBottom = Int16(sHeight)-(g_vcOpt.SampleWidth+2)
        g_vcSym.IsContrastNormal = 1
        g_vcOpt.Prefiltering = 0
        g_vcOpt.Prefiltering |= 1    // Median Filter
//            g_vcOpt.Prefiltering |= (short) 2;    // 2x2 Avg Filter
//            g_vcOpt.Prefiltering |= (short) 4;    // No Z-Factor
//            g_vcOpt.Prefiltering |= (short) 8;    // No SmoothStep
        g_vcOpt.FilterSize = 0            // (Not used)
        g_vcOpt.FilterIterations = 0     // (Not used)
        g_vcOpt.SymbolType = 0
        
        let width = Int32(sWidth)
        let height = Int32(sHeight)
        
        var nReturnVal: Int32 = 0
        
        if pbmp[0] == 66 && pbmp[1] == 77 {
            if sWidth>1600 || sHeight>1200
            {
                print(" is too large.BitMap, 1600x1200")
                self.hud.dismiss()
                self.showToast(message: "BitMap is too large. Please scan again.")
                return
            }
            //pbmp[28] == 24 colordepth = 24
            
            let pimg = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(sWidth * sHeight))
            let offsetBit = Int(pbmp[13]) * 256 * 256 * 256 + Int(pbmp[12]) * 256 * 256 + Int(pbmp[11]) * 256 + Int(pbmp[10]) * 1
//            let headerSize = Int(pbmp[17]) * 256 * 256 * 256 + Int(pbmp[16]) * 256 * 256 + Int(pbmp[15]) * 256 + Int(pbmp[14]) * 1
//            let imageSize = Int(pbmp[37]) * 256 * 256 * 256 + Int(pbmp[36]) * 256 * 256 + Int(pbmp[35]) * 256 + Int(pbmp[34]) * 1
//            print(offsetBit)
//            print(headerSize)
//            print(imageSize)
            let aWidth = 3 * sWidth
            for row in 0 ..< sHeight
            {
                for col in 0 ..< sWidth
                {
                    pimg[row * sWidth + col] = pbmp[(row*aWidth) + (3*col) + offsetBit]
                    if pimg[row * sWidth + col] < 5{
                        pimg[row * sWidth + col] = 5
                    }
                }
            }
            nReturnVal = vcRead(width, height, pimg, decode_bytes, ach_pw, ach_uid)
        } else {
            nReturnVal = vcRead(width, height, pbmp, decode_bytes, ach_pw, ach_uid)
        }
        
        let scanData = String(cString: decode_bytes)
        print(nReturnVal)
        print(scanData)
        
        if nReturnVal < 0 {
            self.hud.dismiss()
            switch nReturnVal {
            case -1:  
                self.showToast(message: "CRC failure. Please scan again.")
                break
            case -2: 
                self.showToast(message: "R-S failure. Please scan again.")
                break
            case -3:
                self.showToast(message: "Shape Check failure. Please scan again.")
                break
            case -4:
                self.showToast(message: "Nothing found failure. Please scan again.")
                break
            case -5:
                self.showToast(message: "Unknown failure. Please scan again.")
                break
            case -7:
                self.showToast(message: "Bad Fixed Matrix Size. Please scan again.")
                break
            case -9:
                self.showToast(message: "Security failure. Please scan again.")
                break
            default:
                self.showToast(message: String(nReturnVal) + ". Please scan again.")
                break
            }
            
            return
        }
        self.hud.dismiss()
        let numOccurrences = scanData.filter{ $0 == "?" }.count
        if numOccurrences > 20 {
            self.showToast(message: "You need to register the device. Please email us info@veritecinc.com.")
            return
        }
        self.showToast(message: "Scanning vericode success.")
        
        self.getCardByUID(scanData)
        self.hud.dismiss()
    }
    
    func getCardByUID(_ scanData: String) {
        var encodedType = ENC_TYPE_GENERAL
        var uID = ""
        let cardData = scanData.replacingOccurrences(of: "#", with: "\"")
        let parts = cardData.split(separator: "~")
        if (parts.count > 3 && parts[0].count < 20){
            encodedType = ENC_TYPE_OPTIMIZE
        }
        
        if (encodedType == ENC_TYPE_GENERAL){
            guard let obj = Utils.convertStringToDictionary(text: cardData) else {
                self.showToast(message: "Scanned data is not valid. Please scan again.")
                return
            }
            uID = obj["unique_id"] as! String
        } else {
            uID = String(parts[1])
        }
        
        self.hud.show(in: self.view)
        API.getCardByUid(unique_id: uID, token: curUser.token, onSuccess: { response in
            self.searchedCard = response
            self.getProgram()
        }, onFailed: { err in
            self.hud.dismiss()
            self.showToast(message: err)
        })
        uploadScanInfo(scanData)
    }
    
    func getProgram() {
        let programId = searchedCard["program_id"] as! Int
        API.getCardProgram(id: programId, token: curUser.token, onSuccess: { resp in
            self.hud.dismiss()
            self.selectedProg = resp
            self.gotoCardView()
        }, onFailed: { error in
            self.hud.dismiss()
            self.showToast(message: error)
        })
    }
    
    func gotoCardView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CardVC") as! CardVC
        vc.title = "Optical Scan"
        vc.selCard = self.searchedCard
        vc.selectedProg = self.selectedProg
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func uploadScanInfo(_ scanInfo: String) {
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        API.scanCard(scan_data: scanInfo, scan_type: String(SCAN_TYPE_CAMERA), user_id: String(curUser.user_id), dev_id: uuid, token: curUser.token, onSuccess: { resp in
            self.showToast(message: "Scan Information upload success.")
        }, onFailed: { err in
            self.showToast(message: "Scan Information uploading failed.")
        })
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

extension ScanVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // dispose system shutter sound
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        isCapturing = false
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error while generating image from photo capture data.")
            self.showToast(message: "Error while generating image from photo capture data.")
            self.hud.dismiss()
            return
        }
        guard let qrImage = UIImage(data: imageData) else {
            print("Unable to generate UIImage from image data.");
            self.showToast(message: "Unable to generate UIImage from image data.")
            self.hud.dismiss()
            return
        }
        let img = Utils.cropToBounds(image: qrImage, overlay: self.overlayView, fullscreen: self.preview)
        self.encodeImg = img.mono
        self.scanedImg.image = self.encodeImg
        self.decodeCardData()
     }
}
