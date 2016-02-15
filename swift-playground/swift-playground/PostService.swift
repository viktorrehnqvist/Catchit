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
        // Http-request
        // Extract data from JSON
        let post = Post(username: "testname", achievement: "testachievement", score: 1, imageUrl: "testurl")
        if delegate != nil {
            delegate?.setPosts(post)
        }
    }
}