//
//  AchievementsCollectionReusableView.swift
//  swift-playground
//
//  Created by viktor johansson on 29/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class AchievementsCollectionReusableView: UICollectionReusableView {
    // MARK: Setup
    @IBOutlet weak var achievementDescription: UILabel!
    @IBOutlet weak var achievementCompleterCount: UILabel!
    @IBOutlet weak var achievementScore: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var completersButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var bucketlistButton: UIButton!
    
}
