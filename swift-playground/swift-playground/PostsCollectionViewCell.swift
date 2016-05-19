//
//  PostsCollectionViewCell.swift
//  swift-playground
//
//  Created by viktor johansson on 11/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class PostsCollectionViewCell: UICollectionViewCell {
    
    // MARK: Setup
    let postService = PostService()
    var postId: Int?
    let likeActiveImage = UIImage(named: "heart-icon-active")
    let likeInactiveImage = UIImage(named: "heart-icon-inactive")
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var buttonContainer: UIStackView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: User Interaction
    @IBAction func pressLikeButton(sender: AnyObject) {
        postService.likePost(postId!)
        if (likeButton?.currentImage == likeInactiveImage) {
            let newLikeCount:Int! = Int(likeCount.text!)! + 1
            likeCount?.text = String(newLikeCount)
            likeButton?.setImage(likeActiveImage, forState: .Normal)
        } else {
            let newLikeCount:Int! = Int(likeCount.text!)! - 1
            likeCount?.text = String(newLikeCount)
            likeButton?.setImage(likeInactiveImage, forState: .Normal)
        }
    }
    
}
