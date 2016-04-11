//
//  AchievementsCollectionReusableView.swift
//  swift-playground
//
//  Created by viktor johansson on 29/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class AchievementsCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var bucketlistImage: UIImageView! {
        didSet { setupShit() }
    }
    
    func setupShit() {
        
    }
}
