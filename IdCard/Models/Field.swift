//
//  Field.swift
//  IdCard
//
//  Created by XiangHao on 12/30/23.
//

import Foundation

public class Field {
    public var label                : String = ""
    public var placeholder          : String = ""
    public var type                 : String = ""
    public var name                 : String = ""
    public var value                : String = ""
    public var extend               : Bool = false
    public var removable            : Bool = false
//    public TextInputLayout txtLayout;
//    public EditText  editTxt;
    public var side                 : Int = DISP_CARD_NONE
    public var xpos                 : Int = 88
    public var ypos                 : Int = 160
    public var color                : String = ""
    public var size                 : Int = 14
    
    var dictionary: [String: Any] {
        return [
            "label": label,
            "placeholder": placeholder,
            "type": type,
            "name": name,
            "value": value,
            "extend": extend,
            "removable": removable,
            "side": side,
            "xpos": xpos,
            "ypos": ypos,
            "color": color,
            "size": size,
        ]
    }
    
    init() {}
    
    init(dictionary : [String: Any]){
        for (key, value) in dictionary {
            if let _ = value as? NSNull {
                continue
            }
            switch key {
                case "label": 
                    self.label = value as! String
                case "placeholder":
                    self.placeholder = value as! String
                case "type":
                    self.type = value as! String
                case "name":
                    self.name = value as! String
                case "value":
                    self.value = value as! String
                case "extend":
                    self.extend = value as! Bool
                case "removable":
                    self.removable = value as! Bool
                case "side":
                    self.side = Utils.AnyToInt(value: value)
                case "xpos": 
                    self.xpos = Utils.AnyToInt(value: value)
                case "ypos":
                    self.ypos = Utils.AnyToInt(value: value)
                case "color":
                    self.color = value as! String
                case "size":
                    self.size = Utils.AnyToInt(value: value)
                default:
                    break
            }
        }
    }
}
