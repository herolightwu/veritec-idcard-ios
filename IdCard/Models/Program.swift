//
//  Program.swift
//  IdCard
//
//  Created by XiangHao on 12/30/23.
//

import Foundation

public class Program {
    public var program_id               : Int = -1
    public var program_name             : String = ""
    public var program_enabled          : Bool = true
    public var program_template         : [[String: Any]] = []
    public var card_image_front         : String = ""
    public var card_image_back          : String = ""
    public var logo                     : String = ""
    public var compression              : Int = 0
    public var edac                     : Int = 0
    public var matrix_size              : Int = 0
    public var pxpcw                    : Int = 0
    public var sample_width             : Int = 0
    public var created_date             : String = ""     //"2022-07-25T00:00:00.000Z",
    public var prefilter                : Bool = false
    public var created_user             : Int = 0
    public var modified_date            : String = ""    //"2022-07-25T00:00:00.000Z",
    public var modified_user            : Int = 0
    public var printed_size             : String = "small"
    public var jsonbarcode              : [String: Any] = [String: Any]()
    
    var dictionary: [String: Any] {
        return [
            "program_id": program_id,
            "program_name": program_name,
            "program_enabled": program_enabled,
            "program_template": program_template,
            "card_image_front": card_image_front,
            "card_image_back": card_image_back,
            "logo": logo,
            "compression": compression,
            "edac": edac,
            "matrix_size": matrix_size,
            "pxpcw": pxpcw,
            "sample_width": sample_width,
            "created_date": created_date,
            "prefilter": prefilter,
            "created_user": created_user,
            "modified_date": modified_date,
            "modified_user": modified_user,
            "printed_size": printed_size,
            "jsonbarcode": jsonbarcode
        ]
    }
    
    init() {}
    
    init(dictionary : [String: Any]){
        for (key, value) in dictionary {
            if let _ = value as? NSNull {
                continue
            }
            switch key {
                case "program_id":
                    self.program_id = Utils.AnyToInt(value: value)
                case "program_name":
                    self.program_name = value as! String
                case "program_enabled":
                    self.program_enabled = value as! Bool
                case "program_template":
                self.program_template = value as! [[String: Any]]
                case "card_image_front":
                    self.card_image_front = value as! String
                case "card_image_back":
                    self.card_image_back = value as! String
                case "logo":
                    self.logo = value as! String
                case "compression":
                    self.compression = Utils.AnyToInt(value: value)
                case "edac":
                    self.edac = Utils.AnyToInt(value: value)
                case "matrix_size":
                    self.matrix_size = Utils.AnyToInt(value: value)
                case "pxpcw":
                    self.pxpcw = Utils.AnyToInt(value: value)
                case "sample_width":
                    self.sample_width = Utils.AnyToInt(value: value)
                case "created_date":
                    self.created_date = value as! String
                case "prefilter":
                    self.prefilter = value as! Bool
                case "created_user":
                    self.created_user = Utils.AnyToInt(value: value)
                case "modified_date":
                    self.modified_date = value as! String
                case "modified_user":
                    self.modified_user = Utils.AnyToInt(value: value)
                case "printed_size":
                    self.printed_size = value as! String
                case "jsonbarcode":
                    self.jsonbarcode = value as! [String: Any]
                default:
                    break
            }
        }
    }
}
