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
    func setAchievements(json: AnyObject)
}

class AchievementService {
    
    var delegate: AchievementServiceDelegate?
    
    func getAchievements() {
        Alamofire.request(.GET, "http://192.168.0.103:3000/achievements.json/")
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setAchievements(JSON)
                        })
                    }
                }
        }

    }
    
    func fetchMoreAchievements(lastAchievementId: Int) {
        Alamofire.request(.GET, "http://192.168.0.103:3000/achievements.json/", parameters: ["achievements": lastAchievementId])
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setAchievements(JSON)
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
                    "http://192.168.1.116:3000/uploads",
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
        Alamofire.download(.GET, "http://192.168.1.116:3000/capturedvideo.mov") { temporaryURL, response in
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let pathComponent = response.suggestedFilename
            let fileUrl = directoryURL.URLByAppendingPathComponent(pathComponent!)
            Alamofire.upload(
                .POST,
                "http://192.168.1.116:3000/uploads",
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
