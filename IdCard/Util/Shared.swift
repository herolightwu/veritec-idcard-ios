//
//  Shared.swift
//  IdCard
//
//  Created by XiangHao on 1/2/24.
//

import Foundation

var curUser : User = User()

let defaults = UserDefaults(suiteName: "group.com.veritecinc.IdCard")!
let kUserPassword = "kUserPassword"
let kUserEmail = "kUserEmail"
let kLibLicense = "kLibLicense"

func getUserEmail() -> String {
    if let email = defaults.string(forKey: kUserEmail) {
        return email
    }
    return ""
}

func setUserEmail(_ email: String) {
    defaults.set(email, forKey: kUserEmail)
    defaults.synchronize()
}

func getUserPassword() -> String {
    if let password = defaults.string(forKey: kUserPassword) {
        return password
    }
    return ""
}

func setUserPassword(_ password: String) {
    defaults.set(password, forKey: kUserPassword)
    defaults.synchronize()
}

func getLibLicense() -> String {
    if let key = defaults.string(forKey: kLibLicense) {
        return key
    }
    return "DEMO"
}

func setLibLicense(_ license: String) {
    defaults.set(license, forKey: kLibLicense)
    defaults.synchronize()
}

