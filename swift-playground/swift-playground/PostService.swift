//
//  PostService.swift
//  swift-playground
//
//  Created by viktor johansson on 15/02/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation

protocol PostServiceDelegate {
    func setPosts(post: Post)
}

class PostService {
    
    var delegate: PostServiceDelegate?
    
    func getPosts() {
        let path = "http://192.168.1.116:3000/posts.json"
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!)
        let post = Post(username: "testname", achievement: "testachievement", score: 1, imageUrl: "testurl")
        task.resume()
        print(task)
        if delegate != nil {
            delegate?.setPosts(post)
        }
    }
}

