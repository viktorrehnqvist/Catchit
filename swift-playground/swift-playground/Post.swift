//
//  Post.swift
//  swift-playground
//
//  Created by viktor johansson on 13/02/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation

struct Post {
    let username: String
    let achievement: String
    let score: Int
    let imageUrl: String
    
    init(username: String, achievement: String, score: Int, imageUrl: String) {
        self.username = username
        self.achievement = achievement
        self.score = score
        self.imageUrl = imageUrl
    }
}
