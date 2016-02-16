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
    func setPosts(post: Post)
}

class PostService {
    
    var delegate: PostServiceDelegate?
    
    func getPosts() {
        Alamofire.request(.GET, "http://192.168.1.116:3000/uploads.json")
            .responseJSON { response in
                let data = response.result
                print(data)
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

}
