//
//  UserService.swift
//  swift-playground
//
//  Created by viktor johansson on 27/04/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import Alamofire

protocol UserServiceDelegate {
    func setUserData(json: AnyObject)
}

class UserService {
    
    var delegate: UserServiceDelegate?
    let currentUserId = NSUserDefaults.standardUserDefaults().objectForKey("id") as? Int
    let headers = NSUserDefaults.standardUserDefaults().objectForKey("headers") as? [String : String]
    
    func getCurrentUserData() {
        Alamofire.request(.GET, "http://192.168.1.116:3000/users/\(currentUserId!).json/", headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setUserData(JSON)
                        })
                    }
                }
                
        }
    }
    
    func getUserData(userId: Int) {
        Alamofire.request(.GET, "http://192.168.1.116:3000/users/\(userId).json/", headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setUserData(JSON)
                        })
                    }
                }
                
        }

    }

}
