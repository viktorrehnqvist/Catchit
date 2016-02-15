//
//  ViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 12/02/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PostServiceDelegate {

    let postService = PostService()
    
    func setPosts(post: Post) {
        // Display fetched posts
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

