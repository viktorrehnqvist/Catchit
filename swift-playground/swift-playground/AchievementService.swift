//
//  AchievementService.swift
//  swift-playground
//
//  Created by viktor johansson on 11/04/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Protocols
protocol AchievementServiceDelegate {
    func setAchievementData(json: AnyObject, firstFetch: Bool)
}

class AchievementService {
    
    // MARK: Setup
    var delegate: AchievementServiceDelegate?
    let headers = NSUserDefaults.standardUserDefaults().objectForKey("headers") as? [String : String]
    let userId = NSUserDefaults.standardUserDefaults().objectForKey("id") as? Int
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    
    // MARK: GET-Requests
    func getAchievements() {
        Alamofire.request(.GET, url + "achievements.json/", headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setAchievementData(JSON, firstFetch: true)
                        })
                    }
                }
        }

    }
    
    func getAchievement(achievementId: Int) {
        Alamofire.request(.GET, url + "achievements/\(achievementId).json/", headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setAchievementData(JSON, firstFetch: true)
                        })
                    }
                }
        }
        
    }
    
    func getBucketlist() {
        Alamofire.request(.GET, url + "users/\(userId!).json/", headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setAchievementData(JSON, firstFetch: true)
                        })
                    }
                }
        }
    }
    
    func fetchMoreAchievements(lastAchievementId: Int) {
        Alamofire.request(.GET, url + "achievements.json/", parameters: ["achievements": lastAchievementId], headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setAchievementData(JSON, firstFetch: false)
                        })
                    }
                }
        }
    }
    
    func fetchMorePostsForAchievement(lastPostId: Int, achievementId: Int) {
        Alamofire.request(.GET, url + "posts.json", parameters: ["id": lastPostId, "achievement": achievementId], headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setAchievementData(JSON, firstFetch: false)
                        })
                    }
                }
        }
    }

    func getCompleters(achievementId: Int) {
        Alamofire.request(.GET, url + "achievements/\(achievementId).json/", headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setAchievementData(JSON, firstFetch: true)
                        })
                    }
                }
        }
        
    }
    
    // MARK: PUT-Requests
    func addToBucketlist(achievementId: Int) {
        Alamofire.request(.PUT, url + "bucket_list/add_bucket_list_item/\(achievementId)", headers: headers)
    }
    
    // MARK: DELETE-Requests
    func removeFromBucketlist(achievementId: Int) {
        Alamofire.request(.DELETE, url + "bucket_list/remove_bucket_list_item/\(achievementId)", headers: headers)
    }
    
}
