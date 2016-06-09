//
//  LikesViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 22/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class LikesViewController: UIViewController, PostServiceDelegate, AchievementServiceDelegate, UserServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Setup
    let postService = PostService()
    let achievementService = AchievementService()
    let userService = UserService()
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noRecordsImageView: UIImageView!
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var typeIs: String!
    var userId: Int?
    var postId: Int?
    var achievementId: Int?
    var userNames: [String] = []
    var userIds: [Int] = []
    var userAvatarUrls: [String] = []
    var userAvatars: [UIImage] = []
    
    // MARK: Lifecycle
    func setPostData(json: AnyObject) {
        userNames = (json["like_infos"] as! NSArray)[0] as! [String]
        userAvatarUrls = (json["like_infos"] as! NSArray)[1] as! [String]
        userIds = (json["like_infos"] as! NSArray)[2] as! [Int]
        loadAvatars()
        collectionView.removeIndicators()
    }
    
    func updatePostData(json: AnyObject) {
    }
    
    func setNewPostData(json: AnyObject) {
    }
    
    func setAchievementData(json: AnyObject, firstFetch: Bool) {
        userIds = (json["completer_infos"] as! NSArray)[0] as! [Int]
        userNames = (json["completer_infos"] as! NSArray)[1] as! [String]
        userAvatarUrls = (json["completer_infos"] as! NSArray)[2] as! [String]
        loadAvatars()
        collectionView.removeIndicators()
    }
    
    func updateAchievementsData(json: AnyObject) {
    }
    
    func setNewAchievementData(json: AnyObject) {
    }
    
    func setUserData(json: AnyObject, follow: Bool) {
        if follow {
            userNames = (json["follow_infos"] as! NSArray)[0] as! [String]
            userAvatarUrls = (json["follow_infos"] as! NSArray)[1] as! [String]
            userIds = (json["follow_infos"] as! NSArray)[2] as! [Int]
        } else {
            userNames = (json["follower_infos"] as! NSArray)[0] as! [String]
            userAvatarUrls = (json["follower_infos"] as! NSArray)[1] as! [String]
            userIds = (json["follower_infos"] as! NSArray)[2] as! [Int]
        }
        loadAvatars()
        collectionView.removeIndicators()
    }
    
    func updateUserData(json: AnyObject) {
    }
    
    func setNoticeData(notSeenNoticeCount: Int) {
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.loadIndicatorMid(screenSize, style: UIActivityIndicatorViewStyle.Gray)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.hidesBarsOnSwipe = false
        noRecordsImageView.hidden = true
        switch typeIs! {
        case "post":
            self.postService.delegate = self
            self.noRecordsImageView.image = UIImage(named: "no-posts")
            postService.getPost(postId!)
        case "achievementCompleters":
            self.achievementService.delegate = self
            self.noRecordsImageView.image = UIImage(named: "no-bucketlist")
            achievementService.getCompleters(achievementId!)
        case "achievementShare":
            self.userService.delegate = self
            self.noRecordsImageView.image = UIImage(named: "no-posts")
            userService.getCurrentUserData()
        case "follows":
            self.userService.delegate = self
            self.noRecordsImageView.image = UIImage(named: "no-bucketlist")
            userService.getFollowData(userId!, follow: true)
        case "followers":
            self.userService.delegate = self
            self.noRecordsImageView.image = UIImage(named: "no-bucketlist")
            userService.getFollowData(userId!, follow: false)
        default:
            print("Switch case error")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userIds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("noticeCell", forIndexPath: indexPath) as! NoticeCollectionViewCell
        
        let noticeCellTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        cell.tag = indexPath.row
        cell.addGestureRecognizer(noticeCellTapGesture)
        cell.noticeLabel.text! = userNames[indexPath.row]
        cell.noticeImage.image = userAvatars[indexPath.row]
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.noticeButton.layer.cornerRadius = 5
        
        if typeIs == "achievementShare" {
            cell.noticeButton.hidden = false
            let noticeButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector (shareAchievement(_:)))
            cell.noticeButton.addGestureRecognizer(noticeButtonTapGesture)
        }
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let size = CGSize(width: screenSize.width, height: 50)
            
            return size
    }
    
    // MARK: User Interaction
    @IBAction func showProfile(sender: AnyObject?) {
        self.performSegueWithIdentifier("showProfileFromLikes", sender: sender)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func shareAchievement(sender: AnyObject?) {
        let point = sender?.view
        let mainCell = point?.superview
        let main = mainCell?.superview
        let thisCell: NoticeCollectionViewCell = main as! NoticeCollectionViewCell
        thisCell.noticeButton.hidden = true
        let cellIndex = thisCell.tag
        let noticeUserId = userIds[cellIndex]
        userService.shareAchievement(noticeUserId, achievementId: achievementId!)
    }
    
    // Mark: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        let point = sender?.view
        let thisCell: NoticeCollectionViewCell = point as! NoticeCollectionViewCell
        let cellIndex = thisCell.tag
        
        if segue.identifier == "showProfileFromLikes" {
            let vc = segue.destinationViewController as! ProfileViewController
            vc.userId = userIds[cellIndex]
        }
    }
    
    // MARK: Additional Helpers
    func loadAvatars() {
        if self.userAvatarUrls.count > 0 {
            for avatarUrl in self.userAvatarUrls {
                let url = NSURL(string: self.url + avatarUrl)
                let data = NSData(contentsOfURL:url!)
                if data != nil {
                    userAvatars.append(UIImage(data: data!)!)
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
        } else {
            // No records loaded.
            self.collectionView.backgroundColor = UIColor(red: 0.1647, green: 0.2157, blue: 0.2902, alpha: 1.0)
            noRecordsImageView.hidden = false
        }
    }
    
}