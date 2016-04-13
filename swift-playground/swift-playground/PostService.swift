//
//  PostService.swift
//  swift-playground
//
//  Created by viktor johansson on 15/02/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import Alamofire

protocol PostServiceDelegate {
    func setPosts(json: AnyObject)
}

class PostService {
    
    var delegate: PostServiceDelegate?
    
    func getPosts() {
        Alamofire.request(.GET, "http://localhost:3000/posts.json/")
            .responseJSON { response in
                print(response)
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setPosts(JSON)
                        })
                    }
                }
                
        }
    }
    
    func fetchMorePosts(lastPostId: Int) {
        Alamofire.request(.GET, "http://localhost:3000/posts.json/", parameters: ["id": lastPostId])
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setPosts(JSON)
                        })
                    }
                }
        }
    }
    
    func createPost() {
        let parameters = [
            "task": [
                "user_id": 1,
                "title": "test",
                "completed": true
            ]
        ]
        Alamofire.request(.POST, "http://192.168.1.116:3000/tasks.json", parameters: parameters)
    }
    
    func updatePost() {
        let parameters = [
            "task": [
                "user_id": 1,
                "title": "false",
                "completed": true
            ]
        ]
        Alamofire.request(.PUT, "http://192.168.1.116:3000/tasks/1.json", parameters: parameters)
    }
    
    func destroyPost() {
        Alamofire.request(.DELETE, "http://192.168.1.116:3000/tasks/1.json")
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
            let test = directoryURL.URLByAppendingPathComponent(pathComponent!)
            Alamofire.upload(
                .POST,
                "http://192.168.1.116:3000/uploads",
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(fileURL: test, name: "avatar", fileName: "test3.mov", mimeType: "video/quicktime")
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
            return test
        }
    }
    
    func getWithHeaders() {
        let headers = [
            "X-User-Email": "ios@ios.com",
            "X-User-Token": "wxKc3_wy1txSwbLgYpKr"
        ]
    
        Alamofire.request(.GET, "http://localhost:3000/secret/index", headers: headers)
        .responseString { response in
            print("Success: \(response.result.isSuccess)")
            print("Response String: \(response.result.value)")
        }
    }



}
