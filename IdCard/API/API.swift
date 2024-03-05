//
//  API.swift
//  IdCard
//
//  Created by XiangHao on 12/30/23.
//

import Foundation
import Alamofire

public class API {
    private static var baseUrl           :String! = "https://api.idcard.veritecinc.com/" //"https://api.idcard.dev.veritecinc.com/" 
    private static var apiUrl            :String! = baseUrl + "api/"

    private static var login             :String! = apiUrl + "login/"
    private static var logout            :String! = apiUrl + "logout/"
    private static var allprograms       :String! = apiUrl + "allcardprograms/"
    private static var cardprogram       :String! = apiUrl + "cardprogram/"
    private static var cards_url         :String! = apiUrl + "cards/"
    private static var cardid            :String! = apiUrl + "cardid/"
    private static var scan_url          :String! = apiUrl + "scandata/"
    private static var encode_url        :String! = apiUrl + "encode"
    private static var forgotpassword    :String! = apiUrl + "forgotpassword"
    private static var resetpassword     :String! = apiUrl + "password/"
    private static var compress_image    :String! = apiUrl + "compress_image"
    
    public static func compressImage(file: String, onSuccess:@escaping ((_ webpfile: String) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void))) {
        let params:Parameters = [
            "file": file
        ]
        
        AF.request(compress_image, method: HTTPMethod.post, parameters: params)
            .responseJSON{ (response) in
                switch response.result {
                    case .success( let value ):
                        let resp = value as! [String: Any]
                        if resp["status"] as! String == "success" {
                            onSuccess(resp["webp"] as! String)
                        } else {
                            onFailed(resp["message"] as! String)
                        }
                        break
                    case .failure(let err):
                        let er = err as AFError
                        print(er.errorDescription!)
                        onFailed(er.errorDescription!)
                }
            }
    }
    
    public static func resetPassword(token: String, uid: String, new_pass: String, old_pass: String, email: String, onSuccess:@escaping ((_ resp: String) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void))) {
        let url = resetpassword + uid
        let params:Parameters = [
            "old_password": old_pass,
            "new_password": new_pass,
            "email": email
        ]
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        AF.request(url, method: HTTPMethod.put, parameters: params, headers: header)
            .responseJSON{ (response) in
                switch response.result {
                    case .success( let value ):
                        let resp = value as! [String: Any]
                        if resp["status"] as! String == "error" || resp["status"] as! String == "unauthorized"{
                            onFailed(resp["message"] as! String)
                        } else {
                            onSuccess("Success. Password has changed.")
                        }
                        break
                    case .failure(let err):
                        let er = err as AFError
                        print(er.errorDescription!)
                        onFailed(er.errorDescription!)
                }
        }
    }
    
    public static func forgotPassword(token: String, email: String, onSuccess:@escaping ((_ resp: String) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        
        let params:Parameters = [
            "email": email
        ]
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        AF.request(forgotpassword, method: HTTPMethod.put, parameters: params, headers: header)
            .responseJSON{ (response) in
                switch response.result {
                    case .success( let value ):
                        let resp = value as! [String: Any]
                        if resp["status"] as! String == "error" {
                            onFailed(resp["message"] as! String)
                        } else {
                            onSuccess("Success. Please check your email.")
                        }
                        break
                    case .failure(let err):
                        let er = err as AFError
                        print(er.errorDescription!)
                        onFailed(er.errorDescription!)
                }
            }
    }

    public static func editCard(user: User, cid: String, face_image: String, comp_image: String, code_f: String, server_f: String, encoded: String, onSuccess:@escaping ((_ resp: String) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        
        let params:Parameters = [
            "card_id": cid,
            "face_image": face_image,
            "compressed_face_image": comp_image,
            "code_fields": code_f,
            "server_fields": server_f,
            "barcode": encoded,
            "card_status": "true",
            "modified_user": String(user.user_id)
        ]
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + user.token,
            "Accept": "application/json"
        ]
        
        AF.request(cards_url, method: HTTPMethod.put, parameters: params, headers: header)
            .responseJSON{ (response) in
                switch response.result {
                case .success( let value):
                    let resp = value as! [String: Any]
                    if resp["status"] as! String == "success" {
                        onSuccess(resp["message"] as! String)
                    } else {
                        onFailed(resp["message"] as! String)
                    }
                    break
                case .failure(let err):
                    let er = err as AFError
                    print(er.errorDescription!)
                    onFailed("Update card failed. Please try to do the action again")
                }
            }
        
    }

    public static func orderCard(user: User, uid: String, face_image: String, comp_image: String, pid: Int, code_f: String, server_f: String, encoded: String, onSuccess:@escaping ((_ resp: String) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        
        let params:Parameters = [
            "unique_id": uid,
            "face_image": face_image,
            "compressed_face_image": comp_image,
            "program_id": String(pid),
            "code_fields": code_f,
            "server_fields": server_f,
            "barcode": encoded,
            "nfc_fields": "",
            "created_user": String(user.user_id),
            "modified_user": String(user.user_id),
            "available": "true"
        ]
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + user.token,
            "Accept": "application/json"
        ]
        
        AF.request(cards_url, method: HTTPMethod.post, parameters: params, headers: header)
            .responseJSON{ (response) in
                switch response.result {
                case .success( let value):
                    let resp = value as! [String: Any]
                    if resp["status"] as! String == "success" {
                        onSuccess(resp["message"] as! String)
                    } else {
                        onFailed(resp["message"] as! String)
                    }
                    break
                case .failure(let err):
                    let er = err as AFError
                    print(er.errorDescription!)
                    onFailed("Order card failed. Please try to do the action again")
                }
            }
    }

    public static func encodeData(token: String, body: Parameters, onSuccess:@escaping ((_ resp: String) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        AF.request(encode_url, method: HTTPMethod.post, parameters: body, headers: header)
            .responseJSON{ (response) in
                switch response.result {
                case .success( let value):
                    let resp = value as! [String: Any]
                    if resp["status"] as! String == "error" {
                        onFailed(resp["message"] as! String)
                    } else {
                        if let data = resp["data"] as? String {
                            if data.count > 16 {
                                onSuccess(data)
                            } else {
                                onFailed("There is no encoded data. Please try to order again.")
                            }
                        } else {
                            onFailed("Encode failed")
                        }
                    }
                    break
                case .failure(let err):
                    let er = err as AFError
                    print(er.errorDescription!)
                    onFailed(er.errorDescription!)
                }
            }
    }

    public static func getAllPrograms(token: String, domain: String, onSuccess:@escaping ((_ resp: [Program]) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        
        let params:Parameters = [
            "domain": domain
        ]
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + token,
            "Accept": "application/json"
        ]
        
        AF.request(allprograms, method: HTTPMethod.post, parameters: params, headers: header)
            .responseJSON{ (response) in
                switch response.result {
                    case .success( let value ):
                        let resp = value as! [String: Any]
                        if resp["status"] as! String == "error" {
                            onFailed(resp["message"] as! String)
                        } else {
                            if let dataJson = resp["data"] as? [[String:Any]] {
                                var programs : [Program] = []
                                for item in dataJson {
                                    let one = Program(dictionary: item)
                                    programs.append(one)
                                }
                                onSuccess(programs)
                            } else {
                                onFailed("Invaild Data")
                            }
                        }
                        break
                    case .failure(let err):
                        let er = err as AFError
                        print(er.errorDescription!)
                        onFailed(er.errorDescription!)
                }
            }
    }

    public static func scanCard(scan_data: String, scan_type: String, user_id: String, dev_id: String, token: String, onSuccess:@escaping ((_ resp: String) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        
        let params:Parameters = [
            "information": scan_data,
            "scantype": scan_type,
            "scanned_user": user_id,
            "deviceID": dev_id
        ]
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        AF.request(scan_url, method: HTTPMethod.post, parameters: params, headers: header)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let value):
                    let resp = value as! [String: Any]
                    if resp["status"] as! String == "success" {
                        onSuccess("success")
                    } else {
                        onFailed(resp["message"] as! String)
                    }
                    break
                case .failure(let err):
                    let er = err as AFError
                    print(er.errorDescription!)
                    onFailed(er.errorDescription!)
                }
            }
    }

    public static func getCardByUid(unique_id: String, token: String, onSuccess:@escaping ((_ resp: [String: Any]) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        
        let getUrl = cardid + unique_id
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        AF.request(getUrl, method: HTTPMethod.get, headers: header)
            .responseJSON{ (response) in
                switch response.result {
                case .success( let value):
                    let resp = value as! [String: Any]
                    if resp["status"] as! String == "error" {
                        onFailed(resp["message"] as! String)
                    } else {
                        if let dataJson = resp["data"] as? [[String:Any]] {
                            if dataJson.count > 0 {
                                onSuccess(dataJson[0])
                            } else {
                                onFailed("Invalid data")
                            }
                        } else {
                            onFailed("Invalid data")
                        }
                    }
                    break
                case .failure(let err):
                    let er = err as AFError
                    print(er.errorDescription!)
                    onFailed(er.errorDescription!)
                }
            }
    }

    public static func getCardById(cId: String, token: String, onSuccess:@escaping ((_ resp: [String: Any]) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        let getUrl = cards_url + cId
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        AF.request(getUrl, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: header, interceptor: nil)
            .responseJSON{ (response) in
                switch response.result {
                    case .success( let value ):
                        let resp = value as! [String: Any]
                        if resp["status"] as! String == "error" || resp["status"] as! String == "fail" {
                            onFailed(resp["message"] as! String)
                        } else {
                            if let data = resp["data"] as? [[String: Any]] {
                                if data.count > 0 {
                                    onSuccess(data[0])
                                } else {
                                    onFailed("Invalid Card Number")
                                }
                            } else {
                                onFailed("Invalid Card Number")
                            }
                        }
                        break
                    case .failure(let err):
                        let er = err as AFError
                        print(er.errorDescription!)
                        onFailed(er.errorDescription!)
                }
            }
    }

    public static func getCardProgram(id: Int, token: String, onSuccess:@escaping ((_ resp: Program) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        
        let getUrl = cardprogram + String(id)
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        AF.request(getUrl, method: HTTPMethod.get, headers: header)
            .responseJSON{ (response) in
                switch response.result {
                    case .success( let value ):
                        let resp = value as! [String: Any]
                        if resp["status"] as! String == "error" {
                            onFailed(resp["message"] as! String)
                        } else {
                            if let data = resp["data"] as? [[String: Any]] {
                                let program = Program(dictionary: data[0])
                                onSuccess(program)
                            } else {
                                onFailed("Invalid data")
                            }
                        }
                        break
                    case .failure(let err):
                        let er = err as AFError
                        print(er.errorDescription!)
                        onFailed(er.errorDescription!)
                }
            }
    }

    public static func login(email: String, password: String, onSuccess:@escaping ((_ resp: User) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        
        let params:Parameters = [
            "email": email,
            "password": password
        ]
        
        AF.request(login, method: HTTPMethod.post, parameters: params)
            .responseJSON{ (response) in
                switch response.result {
                    case .success( let value ):
                        let resp = value as! [String: Any]
                        if resp["status"] as! String == "error" {
                            onFailed(resp["message"] as! String)
                        } else {
                            let token = resp["token"] as! String
                            let domain = resp["domain"] as! String
                            if let data = resp["data"] as? [[String: Any]] {
                                let user = User(dictionary: data[0])
                                user.email = email
                                user.password = password
                                user.token = token
                                user.domain = domain
                                if user.user_status == "enabled" {
                                    onSuccess(user)
                                } else {
                                    onFailed("Disabled User")
                                }
                            } else {
                                onFailed("Invalid data")
                            }
                        }
                        break
                    case .failure(let err):
                        let er = err as AFError
                        print(er.errorDescription!)
                        onFailed(er.errorDescription!)
                    }
            }
    }

    public static func logout(token: String, onSuccess:@escaping ((_ resp: String) -> (Void)), onFailed:@escaping ((_ error:String) -> (Void)) ){
        
        let header: HTTPHeaders = [
            "Authorization": "Bearer " + token,
            "Content-Type": "application/json"
        ]
        
        AF.request(logout, method: HTTPMethod.post, headers: header)
            .responseString{ (response) in
                switch response.result {
                case .success( _):
                    onSuccess("success")
                    break
                case .failure(let err):
                    let er = err as AFError
                    print(er.errorDescription!)
                    onFailed(er.errorDescription!)
                }
            }
    }
}
