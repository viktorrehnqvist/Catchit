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
    func setUserData(json: AnyObject, follow: Bool)
}

class UserService {
    
    var delegate: UserServiceDelegate?
    let currentUserId = NSUserDefaults.standardUserDefaults().objectForKey("id") as? Int
    let headers = NSUserDefaults.standardUserDefaults().objectForKey("headers") as? [String : String]
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    
    func getCurrentUserData() {
        Alamofire.request(.GET, url + "users/\(currentUserId!).json/", headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setUserData(JSON, follow: true)
                        })
                    }
                }
                
        }
    }
    
    func getUserData(userId: Int) {
        Alamofire.request(.GET, url + "users/\(userId).json/", headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setUserData(JSON, follow: true)
                        })
                    }
                }
                
        }

    }
    
    func getFollowData(userId: Int, follow: Bool) {
        Alamofire.request(.GET, url + "users/\(userId).json/", headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setUserData(JSON, follow: follow)
                        })
                    }
                }
                
        }

    }

}
