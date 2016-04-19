//
//  LikesViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 22/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class LikesViewController: UIViewController, PostServiceDelegate, AchievementServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let postService = PostService()
    let achievementService = AchievementService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    var typeIsPost: Bool!
    var postId: Int?
    var achievementId: Int?
    var userNames: [String] = []
    var userIds: [Int] = []
    var userAvatarUrls: [String] = []
    var userAvatars: [UIImage] = []

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setPostData(json: AnyObject) {
        userNames = json["like_infos"]!![0] as! [String]
        userAvatarUrls = json["like_infos"]!![1] as! [String]
        userIds = json["like_infos"]!![2] as! [Int]
        loadAvatars()
    }
    
    func setAchievementData(json: AnyObject, firstFetch: Bool) {
        userIds = json["completer_infos"]!![0] as! [Int]
        userNames = json["completer_infos"]!![1] as! [String]
        userAvatarUrls = json["completer_infos"]!![2] as! [String]
        loadAvatars()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if typeIsPost == true {
            self.postService.delegate = self
            postService.getPost(postId!)
        } else {
            self.achievementService.delegate = self
            achievementService.getCompleters(achievementId!)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userIds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("noticeCell", forIndexPath: indexPath) as! NoticeCollectionViewCell
        
        let noticeCellTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        cell.addGestureRecognizer(noticeCellTapGesture)
        cell.noticeLabel.text! = userNames[indexPath.row]
        cell.noticeImage.image = userAvatars[indexPath.row]
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let size = CGSize(width: screenSize.width, height: 50)
            
            return size
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    @IBAction func showProfile(sender: AnyObject?) {
        self.performSegueWithIdentifier("showProfileFromLikes", sender: sender)
    }
    
    func loadAvatars() {
        if self.userAvatarUrls.count > 0 {
            print("avatars loaded")
            for avatarUrl in self.userAvatarUrls {
                print(avatarUrl)
                let url = NSURL(string: "http://localhost:3000" + avatarUrl)
                let data = NSData(contentsOfURL:url!)
                if data != nil {
                    userAvatars.append(UIImage(data: data!)!)
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
        }
    }
    
}