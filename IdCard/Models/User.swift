//
//  User.swift
//  IdCard
//
//  Created by XiangHao on 12/30/23.
//

import Foundation

public class User {
    public var email            :String = ""
    public var password         :String = ""
    public var user_id          :Int = -1
    public var token            :String = ""
    public var domain           :String = ""
    public var user_permissions :String = ""
    public var user_role        :String = ""
    public var user_programs    :String = ""
    public var user_status      :String = ""
    
    var dictionary: [String: Any] {
        return [
            "email": email,
            "password": password,
            "user_id": user_id,
            "token": token,
            "domain": domain,
            "user_permissions": user_permissions,
            "user_role": user_role,
            "user_programs": user_programs,
            "user_status": user_status
        ]
    }
    
    init() {}
    
    init(dictionary : [String: Any]){
        for (key, value) in dictionary {
            if let _ = value as? NSNull {
                continue
            }
            switch key {
                case "email": 
                    self.email = value as! String
                case "password":
                    self.password = value as! String
                case "user_id":
                self.user_id = Utils.AnyToInt(value: value)
                case "token":
                    self.token = value as! String
                case "domain":
                    self.domain = value as! String
                case "user_permissions":
                    self.user_permissions = value as! String
                case "user_role":
                    self.user_role = value as! String
                case "user_programs":
                    self.user_programs = value as! String
                case "user_status":
                    self.user_status = value as! String
                default:
                    break
            }
        }
    }
}
