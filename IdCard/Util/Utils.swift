//
//  Utils.swift
//  IdCard
//
//  Created by XiangHao on 12/30/23.
//

import Foundation
import UIKit
import SDWebImageWebPCoder


class Utils {
    static func AnyToInt(value: Any) -> Int {
        guard let val = value as? String else {
            return value as! Int
        }
        return Int(val)!
    }
    
    static func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func convertCodeToBmp(from barcode: String) -> UIImage? {
        guard barcode.count >= 8 else {
            print("data too small")
            return nil
        }

        let width: Int  = Int(sqrt(Double(barcode.count)))
        let height = width
        let colorSpace = CGColorSpaceCreateDeviceGray()

        guard
            let context = CGContext(data: nil, width: width * 4, height: height * 4, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrderDefault.rawValue), //CGImageAlphaInfo.alphaOnly.rawValue
            let buffer = context.data?.bindMemory(to: UInt8.self, capacity: width * height * 16)
        else {
            return nil
        }

        for indY in 0 ..< height * 4 {
            let offset = indY * width * 4
            for indX in 0 ..< width * 4 {
                if barcode[Int(indX/4) + width * Int(indY/4)] == "1" {
                    buffer[offset + indX] =  UInt8(0)
                } else {
                    buffer[offset + indX] =  UInt8(0xff)
                }
            }
        }

        return context.makeImage().flatMap { UIImage(cgImage: $0) }
    }
    
    static func convertDictionaryToJSON(_ dictionary: [String: Any]) -> String? {
        if dictionary.count == 0 {
            return "{}"
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .withoutEscapingSlashes) else {
           print("Something is wrong while converting dictionary to JSON data.")
           return nil
        }

        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
           print("Something is wrong while converting JSON data to JSON string.")
           return nil
        }

        return jsonString
     }
    
    static func enhanceImage(_ image: UIImage) -> UIImage? {
        guard let sourceImage = CIImage(image: image),
              let filter = CIFilter(name: "CIColorControls") else { return nil }
        
        filter.setValue(sourceImage, forKey: kCIInputImageKey)
        filter.setValue(-10, forKey: kCIInputBrightnessKey)
        guard let output = filter.outputImage else { return nil }
        
        guard let outputCGImage = CIContext().createCGImage(output, from: output.extent) else { return nil }
        
        let filteredImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        return filteredImage
    }
    
    static func convertPngToWebp(_ image: UIImage) -> Data? {
        var quality = 0.5
        var ind = 0
        var lossyWebpData = SDImageWebPCoder.shared.encodedData(with: image, format: .webP, options: [.encodeCompressionQuality: quality])
        repeat{
            if lossyWebpData!.count < WEBP_MIN_SIZE {
                quality = quality + 0.05
            } else if lossyWebpData!.count >= WEBP_MAX_SIZE {
                quality = quality - 0.05
            }
            lossyWebpData = SDImageWebPCoder.shared.encodedData(with: image, format: .webP, options: [.encodeCompressionQuality: quality]) // [0, 1] compression quality
            ind = ind + 1
            if ind == 10 {
                return nil
            }
        } while lossyWebpData!.count < WEBP_MIN_SIZE || lossyWebpData!.count > WEBP_MAX_SIZE
        return lossyWebpData!
    }
    
    static func cropToBounds(image: UIImage, overlay: UIView, fullscreen: UIView) -> UIImage
    {
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        let contextSize: CGSize = contextImage.size
        let widthRatio = contextSize.height/UIScreen.main.bounds.size.width
        let heightRatio = contextSize.width/UIScreen.main.bounds.size.height

        let width = (overlay.frame.size.width)*widthRatio
        let height = (overlay.frame.size.height)*heightRatio
        let x = (contextSize.width/2) - width/2
        let y = (contextSize.height/2) - width/2 // - height/2
        let rect = CGRect(x: x, y: y, width: width, height: width)

        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
        return image
    }
    
    static func getUniqueID() -> String {
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let idArray = uuid.split(separator: "-")
        return String(idArray[1] + idArray[2] + idArray[3])
    }
}
