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
    let auth = NSUserDefaults.standardUserDefaults()
    
    func registerUser(email: String, password: String) {
        let parameters = [
            "user": [
                "email": email,
                "password": password,
            ]
        ]
        auth.setObject(email, forKey: "Email")
        auth.setObject(password, forKey: "Password")
        Alamofire.request(.POST, "http://localhost:3000/users", parameters: parameters)
            .responseJSON { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
        }
    }
    
    func loginUser(email: String, password: String) {
        let parameters = [
            "user": [
                "email": email,
                "password": password,
            ]
        ]
        auth.setObject(email, forKey: "Email")
        auth.setObject(password, forKey: "Password")
        Alamofire.request(.POST, "http://localhost:3000/users/sign_in", parameters: parameters)
            .responseJSON { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
        }
    }
    
    func authUser() {
        let headers = [
            "X-User-Email": auth.objectForKey("Email") as! String,
            "X-User-Token": "tuT7RN9m2T3oNcTkUgDA"
        ]
        
        Alamofire.request(.GET, "http://localhost:3000/posts.json", headers: headers)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
        }
    }
    
}
