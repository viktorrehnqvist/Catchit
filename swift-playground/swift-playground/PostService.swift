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
    func setPostData(json: AnyObject)
    func updatePostData(json: AnyObject)
}

class PostService {
    
    var delegate: PostServiceDelegate?
    let headers = NSUserDefaults.standardUserDefaults().objectForKey("headers") as? [String : String]
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    
    func getPosts() {
        Alamofire.request(.GET, url + "posts.json/", headers: headers)
            .responseJSON { response in
                print(self.headers)
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setPostData(JSON)
                        })
                    }
                }
                
        }
    }
    
    func updatePosts(postIds: [Int], updatedAt: [String]) {
        Alamofire.request(.GET, url + "posts.json/", parameters: ["reload": postIds, "updated_at": updatedAt], headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.updatePostData(JSON)
                        })
                    }
                }
        }
    }
    
    func getPost(postId: Int) {
        Alamofire.request(.GET, url + "posts/\(postId).json/", headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setPostData(JSON)
                        })
                    }
                }
        }
    }
    
    func fetchMorePosts(lastPostId: Int) {
        Alamofire.request(.GET, url + "posts.json/", parameters: ["id": lastPostId], headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setPostData(JSON)
                        })
                    }
                }
        }
    }
    
    func getExplorePosts() {
        Alamofire.request(.GET, url + "explore.json/", headers: headers)
            .responseJSON { response in
                print(response)
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setPostData(JSON)
                        })
                    }
                }
                
        }
    }
    
    func fetchMoreExplorePosts(lastPostId: Int) {
        Alamofire.request(.GET, url + "explore.json/", parameters: ["id": lastPostId], headers: headers)
            .responseJSON { response in
                if let JSON = response.result.value {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setPostData(JSON)
                        })
                    }
                }
        }
    }
    
    func likePost(postId: Int) {
        Alamofire.request(.PUT, url + "posts/like/\(postId)", headers: headers)
    }
    
    func createComment(comment: String, postId: Int) {
        let parameters = [
            "comment": [
                "comment": comment,
                "commenter_id": postId,
                "commenter_type": "post"
            ]
        ]
        Alamofire.request(.POST, url + "/comments?commenter_id=\(postId)&commenter_type=post", parameters: parameters, headers: headers)
    }
    
}
