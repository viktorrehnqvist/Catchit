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
        Alamofire.request(.POST, "http://localhost:3000/users.json", parameters: parameters)
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = response.result.value
                    let userEmail = json!["email"] as! String
                    let userToken = json!["authentication_token"] as! String
                    let headers = ["X-User-Email": userEmail, "X-User-Token": userToken]
                    self.userDefaults.setObject(userEmail, forKey: "email")
                    self.userDefaults.setObject(userToken, forKey: "token")
                    self.userDefaults.setObject(headers, forKey: "headers")
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
        Alamofire.request(.POST, "http://localhost:3000/users/sign_in.json", parameters: parameters)
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = response.result.value
                    let userEmail = json!["email"] as! String
                    let userToken = json!["authentication_token"] as! String
                    let headers = ["X-User-Email": userEmail, "X-User-Token": userToken]
                    self.userDefaults.setObject(userEmail, forKey: "email")
                    self.userDefaults.setObject(userToken, forKey: "token")
                    self.userDefaults.setObject(headers, forKey: "headers")
                } else {
                    print("Could not connect to server")
                }
        }
    }
    
    func authUser() {
        let headers = [
            "X-User-Email": userDefaults.objectForKey("Email") as! String,
            "X-User-Token": "tuT7RN9m2T3oNcTkUgDA"
        ]
        print(headers)
        Alamofire.request(.GET, "http://localhost:3000/posts.json", headers: self.userDefaults.objectForKey("headers") as? [String : String])
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
        }
    }
    
}
