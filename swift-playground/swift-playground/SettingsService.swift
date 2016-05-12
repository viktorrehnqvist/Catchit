//
//  SettingsService.swift
//  Catchit
//
//  Created by viktor johansson on 12/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Protocols
protocol SettingsServiceDelegate {
    func setSettingsData(json: AnyObject)
}

class SettingsService {
    
    // MARK: Setup
    var delegate: SettingsServiceDelegate?
    let currentUserId = NSUserDefaults.standardUserDefaults().objectForKey("id") as? Int
    let headers = NSUserDefaults.standardUserDefaults().objectForKey("headers") as? [String : String]
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: PUT-Requests
    func changeUsername(newUsername: String) {
        let parameters = [
            "user": [
                "name": newUsername
            ]
        ]
        Alamofire.request(.PUT, url + "users/\(currentUserId!).json/", parameters: parameters, headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    self.userDefaults.setObject(JSON["name"], forKey: "name")
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setSettingsData(JSON)

                        })
                    }
                }
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) {
        let parameters = [
            "password": newPassword,
            "password_confirmation": newPassword,
            "current_password": currentPassword
        ]
        Alamofire.request(.PUT, url + "change_password.json", parameters: parameters, headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setSettingsData(JSON)
                    
                        })
                    }
                }
        }
    }
    
    func uploadImage(imageData: NSData) {
        Alamofire.upload(
            .PUT,
            url + "users/\(currentUserId!).json", headers: self.headers,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: imageData, name: "avatar", fileName: "test3.png", mimeType: "image/jpeg")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        if let JSON = response.result.value {
                            if self.delegate != nil {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.delegate?.setSettingsData(JSON)
                                })
                            }
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }

}
