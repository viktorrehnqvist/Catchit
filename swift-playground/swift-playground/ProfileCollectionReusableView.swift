//
//  ProfileCollectionReusableView.swift
//  swift-playground
//
//  Created by viktor johansson on 05/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class ProfileCollectionReusableView: UICollectionReusableView {
    // MARK: Setup
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var achievementCount: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var followCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
}
