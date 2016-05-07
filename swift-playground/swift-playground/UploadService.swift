//
//  UploadService.swift
//  swift-playground
//
//  Created by viktor johansson on 05/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Protocols
protocol UploadServiceDelegate {
    func setUploadedResult(json: AnyObject)
}

class UploadService {
    
    // MARK: Setup
    var delegate: UploadServiceDelegate?
    let headers = NSUserDefaults.standardUserDefaults().objectForKey("headers") as? [String : String]
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    
    // MARK: POST-Requests
    func createPost() {
        let parameters = [
            "task": [
                "title": "test",
                "completed": true
            ]
        ]
        Alamofire.request(.POST, url + "tasks.json", parameters: parameters, headers: headers)
    }
    
    func uploadImage(imageData: NSData, achievementId: Int) {
        Alamofire.upload(
            .POST,
            url + "posts.json", headers: self.headers,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: imageData, name: "image", fileName: "test3.png", mimeType: "image/jpeg")
                multipartFormData.appendBodyPart(data: "\(achievementId)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "achievement_id")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        if let JSON = response.result.value {
                            if self.delegate != nil {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.delegate?.setUploadedResult(JSON)
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

    func uploadVideo(videoUrl: NSURL, achievementId: Int) {
        Alamofire.upload(
            .POST,
            url + "posts.json", headers: self.headers,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: videoUrl, name: "video", fileName: "test3.mov", mimeType: "video/quicktime")
                multipartFormData.appendBodyPart(data: "\(achievementId)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "achievement_id")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        if let JSON = response.result.value {
                            if self.delegate != nil {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.delegate?.setUploadedResult(JSON)
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
