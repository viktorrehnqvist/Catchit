//
//  PostService.swift
//  swift-playground
//
//  Created by viktor johansson on 15/02/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import Alamofire

protocol AuthenticationServiceDelegate {
    func setAuthenticationData(json: AnyObject)
}

class AuthenticationService {
    
    var delegate: AuthenticationServiceDelegate?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func registerUser(email: String, password: String) {
        let parameters = [
            "user": [
                "email": email,
                "password": password,
            ]
        ]
        Alamofire.request(.POST, "http://192.168.1.116:3000/users.json", parameters: parameters)
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = response.result.value
                    // True if registration is complete. This should be changed for better readability.
                    if json!.count > 1 {
                        let userEmail = json?["email"] as! String
                        let userToken = json?["authentication_token"] as! String
                        let userId = json?["id"] as! Int
                        let headers = ["X-User-Email": userEmail, "X-User-Token": userToken]
                        self.userDefaults.setObject(userEmail, forKey: "email")
                        self.userDefaults.setObject(userToken, forKey: "token")
                        self.userDefaults.setInteger(userId, forKey: "id")
                        self.userDefaults.setObject(headers, forKey: "headers")
                    } else {
                        print("Could not create user")
                    }
                } else {
                    print("Could not connect to server")
                }
        }			
    }
    
    func loginUser(email: String, password: String) {
        let parameters = [
            "user": [
                "email": email,
                "password": password,
            ]
        ]
        Alamofire.request(.POST, "http://192.168.1.116:3000/users/sign_in.json", parameters: parameters)
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = response.result.value
                    // True if email and password is corrent. This should be changed for better readability.
                    if json!.count > 1 {
                        let userEmail = json?["email"] as! String
                        let userToken = json?["authentication_token"] as! String
                        let userId = json?["id"] as! Int
                        let headers = ["X-User-Email": userEmail, "X-User-Token": userToken]
                        self.userDefaults.setObject(userEmail, forKey: "email")
                        self.userDefaults.setObject(userToken, forKey: "token")
                        self.userDefaults.setInteger(userId, forKey: "id")
                        self.userDefaults.setObject(headers, forKey: "headers")
                    } else {
                        print("Wrong email or password")
                    }
                } else {
                    print("Could not connect to server")
                }
        }
    }

    
}
