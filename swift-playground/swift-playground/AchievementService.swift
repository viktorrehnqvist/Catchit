//
//  AchievementService.swift
//  swift-playground
//
//  Created by viktor johansson on 11/04/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import Alamofire

protocol AchievementServiceDelegate {
    func setAchievementData(json: AnyObject, firstFetch: Bool)
}

class AchievementService {
    
    var delegate: AchievementServiceDelegate?
    let headers = NSUserDefaults.standardUserDefaults().objectForKey("headers") as? [String : String]
    let userId = NSUserDefaults.standardUserDefaults().objectForKey("id") as? Int
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    
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
    
    func addToBucketlist(achievementId: Int) {
        Alamofire.request(.PUT, url + "bucket_list/add_bucket_list_item/\(achievementId)", headers: headers)
    }
    
    func removeFromBucketlist(achievementId: Int) {
        Alamofire.request(.DELETE, url + "bucket_list/remove_bucket_list_item/\(achievementId)", headers: headers)
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
    
    func toggleInBucketlist() {
        
    }
    
    func shareAchievement() {
        
    }
    
    func getCompleters() {
        
    }
    
    
    func uploadImage() {
        Alamofire.request(.GET, "http://marek.online/wp-content/uploads/2015/09/helloworld1.gif")
            .responseJSON { response in
                let data = response.data
                Alamofire.upload(
                    .POST,
                    self.url + "uploads", headers: self.headers,
                    multipartFormData: { multipartFormData in
                        multipartFormData.appendBodyPart(data: data!, name: "avatar", fileName: "test3.png", mimeType: "image/jpeg")
                    },
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON { response in
                                debugPrint(response)
                            }
                        case .Failure(let encodingError):
                            print(encodingError)
                        }
                    }
                )
        }
    }
    
    func uploadVideo() {
        Alamofire.download(.GET, url + "capturedvideo.mov") { temporaryURL, response in
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let pathComponent = response.suggestedFilename
            let fileUrl = directoryURL.URLByAppendingPathComponent(pathComponent!)
            Alamofire.upload(
                .POST,
                self.url + "uploads", headers: self.headers,
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(fileURL: fileUrl, name: "avatar", fileName: "test3.mov", mimeType: "video/quicktime")
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                    }
                }
            )
            return fileUrl
        }
    }
    
    
    
}
