//
//  common.swift
//  IdCard
//
//  Created by MeiXiang Wu on 5/8/23.
//

import UIKit
import Toast_Swift
import MobileCoreServices


let DISP_CARD_NONE = 0;
let DISP_CARD_FRONT = 1;
let DISP_CARD_BACK = 2;

let CARD_SIZE_WIDTH = 338;
let CARD_SIZE_HEIGHT = 213;

let WEBP_MAX_SIZE = 600
let WEBP_MIN_SIZE = 450

// encoded type
let ENC_TYPE_OPTIMIZE = 1;
let ENC_TYPE_GENERAL = 2;

// webp encode no/yes
let ENC_INCLUDE_WEBP = 96;

let MIN_DATA_SIZE = 700;
let CAPTURE_IMAGE_SIZE = 800;

let IMAGE_WIDTH = 800;
let IMAGE_HEIGHT = 200;

let KEY_VIEW_MODE = "view_mode";
let KEY_ENCODED_TYPE = "encoded_type";
let KEY_PROGRAM_DATA = "program_data";

let KEY_CURRENT_USER = "current_user";
// view mode on CardViewActivity
let VIEW_MODE_SCAN = 1;
let VIEW_MODE_NFC = 2;
let VIEW_MODE_SEARCH = 3;

// Scan type
let SCAN_TYPE_CAMERA = 0;
let SCAN_TYPE_NFC = 1;

// permission name
let PERMISSION_READ = "cards_read";
let PERMISSION_ORDER = "cards_order";
let PERMISSION_EDIT = "cards_edit";
let PERMISSION_PRINT = "cards_print";
let PERMISSION_WRITE = "nfc_write";
let PERMISSION_REJECT = "cards_reject";

// role name
let ROLE_ADMIN = "Administrator";
let ROLE_MANAGER = "Manager";
let ROLE_HOLDER = "Card Holder";
let ROLE_USER = "User";

let MIME_TEXT_PLAIN = "application/x-binary";//text/plain
let NFC_EXTERNAL_TYPE = "nfclab.com:veritecService";


func getLabelColor(_ colorStr: String) -> UIColor {
    switch colorStr {
        case "red":
            return UIColor.red
        case "white":
            return UIColor.white
        case "gray":
            return UIColor.gray
        case "green":
            return UIColor.green
        default:
            return UIColor.black
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    static let yellow = UIColor(rgb:0xFFD200)
    static let dark = UIColor(rgb:0x363C5A)
    static let light = UIColor(rgb: 0xB1B1B1)
    static let error = UIColor(rgb: 0xFF2134)
    static let green = UIColor(rgb: 0x29B52E)
    
    static func random() -> UIColor {
        return UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0)
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

extension String {
    func findIndex(of string: String) -> Int {
        for (index, _) in self.enumerated() {
           var found = true
           for (offset, char2) in string.enumerated() {
               if self[self.index(self.startIndex, offsetBy: index + offset)] != char2 {
                   found = false
                   break
               }
           }
           if found {
               return index
           }
       }
       return -1
    }
    
    func toImage() -> UIImage? {
        var base64Str = self
        if self.contains("base64") {
            let ind = self.findIndex(of: ",") + 1
            let fi = self.index(self.startIndex, offsetBy: ind)
            let range = fi..<self.endIndex
            base64Str = String(self[range])
        }
        if let data = Data(base64Encoded: base64Str, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func removeNewLines(_ delimiter: String = "") -> String {
        var st = self.replacingOccurrences(of: "\n", with: delimiter)
        st = st.replacingOccurrences(of: "\\n", with: delimiter)
        st = st.replacingOccurrences(of: "\\\\", with: "\\")
        st = st.replacingOccurrences(of: "\\\"", with: "\"")
        st = st.replacingOccurrences(of: "\"{", with: "{")
        return st.replacingOccurrences(of: "}\"", with: "}")
//        return st.replacingOccurrences(of: "\"", with: "")
    }
    
    var isNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
    
    func toPointer() -> UnsafeMutablePointer<UInt8>? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        let stream = OutputStream(toBuffer: buffer, capacity: data.count)

        stream.open()
        data.withUnsafeBytes({ (p: UnsafePointer<UInt8>) -> Void in
          stream.write(p, maxLength: data.count)
        })

        stream.close()

        return buffer
      }
}

extension Data {
    func toPointer() -> UnsafeMutablePointer<UInt8>? {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: self.count)
        let stream = OutputStream(toBuffer: buffer, capacity: self.count)

        stream.open()
        self.withUnsafeBytes({ (p: UnsafePointer<UInt8>) -> Void in
          stream.write(p, maxLength: self.count)
        })
        
        stream.close()

        return buffer
      }
}

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {

        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        self.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func base64Encode() -> String? {
        guard let imageData = self.pngData() else
        {
            return nil
        }

        let base64String = imageData.base64EncodedString(options: .lineLength64Characters)
        let fullBase64String = "data:image/png;base64,\(base64String))"

        return fullBase64String
    }
    
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
    
    var mono: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
    
    func toData (options: NSDictionary, type: ImageType) -> Data? {
        guard cgImage != nil else { return nil }
        return toData(options: options, type: type.value)
    }

    // about properties: https://developer.apple.com/documentation/imageio/1464962-cgimagedestinationaddimage
    func toData (options: NSDictionary, type: CFString) -> Data? {
        guard let cgImage = cgImage else { return nil }
        return autoreleasepool { () -> Data? in
            let data = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(data as CFMutableData, type, 1, nil) else { return nil }
            CGImageDestinationAddImage(imageDestination, cgImage, options)
            CGImageDestinationFinalize(imageDestination)
            return data as Data
        }
    }

    // https://developer.apple.com/documentation/mobilecoreservices/uttype/uti_image_content_types
    enum ImageType {
        case image // abstract image data
        case jpeg                       // JPEG image
        case jpeg2000                   // JPEG-2000 image
        case tiff                       // TIFF image
        case pict                       // Quickdraw PICT format
        case gif                        // GIF image
        case png                        // PNG image
        case quickTimeImage             // QuickTime image format (OSType 'qtif')
        case appleICNS                  // Apple icon data
        case bmp                        // Windows bitmap
        case ico                        // Windows icon data
        case rawImage                   // base type for raw image data (.raw)
        case scalableVectorGraphics     // SVG image
        case livePhoto                  // Live Photo

        var value: CFString {
            switch self {
            case .image: return kUTTypeImage
            case .jpeg: return kUTTypeJPEG
            case .jpeg2000: return kUTTypeJPEG2000
            case .tiff: return kUTTypeTIFF
            case .pict: return kUTTypePICT
            case .gif: return kUTTypeGIF
            case .png: return kUTTypePNG
            case .quickTimeImage: return kUTTypeQuickTimeImage
            case .appleICNS: return kUTTypeAppleICNS
            case .bmp: return kUTTypeBMP
            case .ico: return kUTTypeICO
            case .rawImage: return kUTTypeRawImage
            case .scalableVectorGraphics: return kUTTypeScalableVectorGraphics
            case .livePhoto: return kUTTypeLivePhoto
            }
        }
    }
}
