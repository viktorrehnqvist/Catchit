//
//  CollectionViewCell.swift
//  swift-playground
//
//  Created by viktor johansson on 11/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var buttonContainer: UIStackView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func pressLikeButton(sender: AnyObject) {
        // Send like request to API with commentButton.tag
        let lastPartInString = likeCount.text!.endIndex.advancedBy(-18)
        let onlyNumberPartOfString = likeCount.text!.substringToIndex(lastPartInString)
        if (likeButton?.titleLabel?.text == "Gilla") {
            if onlyNumberPartOfString == "Inga" {
                likeCount?.text = "1 gilla-markeringar"
            } else {
                let newLikeCount:Int! = Int(onlyNumberPartOfString)! + 1
                likeCount?.text = String(newLikeCount) + " gilla-markeringar"
            }
            likeButton?.setTitle("Sluta gilla", forState: .Normal)
        } else {
            let newLikeCount:Int! = Int(onlyNumberPartOfString)! - 1
            if newLikeCount == 0 {
                likeCount?.text = "Inga gilla-markeringar"
            } else {
                likeCount?.text = String(newLikeCount) + " gilla-markeringar"
            }
            likeButton?.setTitle("Gilla", forState: .Normal)
        }
    }
    
    
}
