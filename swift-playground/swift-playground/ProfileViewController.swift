//
//  ProfileViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 22/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UserServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    let userService = UserService()
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userId: Int = 43
    var username: String?
    var userAvatar: UIImage?
    var userAvatarUrl: String?
    var userFollowsCount: Int = 0
    var userFollowersCount: Int = 0
    var userScore: Int = 0
    var userAchievementCount: Int = 0
    var follow: Bool?
    var followIds: [Int] = []
    var followerIds: [Int] = []
    var achievementDescriptions: [String] = []
    var achievementIds: [Int] = []
    var achievementScores: [Int] = []
    var postIds: [Int] = []
    var postImageUrls: [String] = []
    var postImages: [UIImage] = []
    var postVideoUrls: [String] = []
    var postCommentCounts: [Int] = []
    var postLikeCounts: [Int] = []
    var postLike: [Bool] = []
    var morePostsToLoad: Bool = true
    
    func setUserData(json: AnyObject) {
        username = json["name"] as? String
        userAchievementCount = (json["achievements"] as! NSArray).count
        userScore = json["user_score"] as! Int
        userFollowsCount = (json["follow_infos"] as! NSArray)[0].count
        userFollowersCount = (json["follower_infos"] as! NSArray)[0].count
        fetchDataFromUrlToUserAvatar((json["avatar_url"] as! String))
        if (json["posts"] as! NSArray).count > 0 {
            for i in 0...((json["posts"] as! NSArray).count - 1) {
                print((json["posts"] as! NSArray)[i])
                achievementDescriptions.append((json["achievements"] as! NSArray)[i]["description"] as! String)
                achievementIds.append((json["posts"] as! NSArray)[i]["achievement_id"] as! Int)
                achievementScores.append((json["achievements"] as! NSArray)[i]["score"] as! Int)
                postIds.append((json["posts"] as! NSArray)[i]["id"] as! Int)
                postImageUrls.append((json["posts"] as! NSArray)[i]["image"]!!["url"] as! String)
                // Handle null! postVideoUrls.append((json[i]?["video_url"])! as! String)
                postCommentCounts.append((json["posts"] as! NSArray)[i]["comments_count"] as! Int)
                postLikeCounts.append((json["posts"] as! NSArray)[i]["likes_count"] as! Int)
                // Check if current user likes the post
                //postLike.append((json["posts"] as! NSArray)[i]["like"] as! Bool)
                // Check if current user follows the displayed user
                fetchDataFromUrlToPostImages((json["posts"] as! NSArray)[i]["image"]!!["url"] as! String)
            }
        } else {
            morePostsToLoad = false
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        userService.getUserData(userId)
        self.userService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postIds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("profileCell", forIndexPath: indexPath) as! CollectionViewCell
        
        let likesTapGesture = UITapGestureRecognizer(target: self, action: #selector(showLikes(_:)))
        let commentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(pressCommentButton(_:)))
        let achievementTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievement(_:)))
        
        cell.tag = indexPath.row
        cell.likeCount.addGestureRecognizer(likesTapGesture)
        cell.commentCount.addGestureRecognizer(commentsTapGesture)
        cell.label.addGestureRecognizer(achievementTapGesture)
        cell.imageView?.image = self.postImages[indexPath.row]
        cell.label?.text = self.achievementDescriptions[indexPath.row]
        cell.commentButton?.tag = indexPath.row
        cell.commentCount?.tag = indexPath.row
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        return cell
        
    }
    
   func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let image = self.postImages[indexPath.row]
        let heightFactor = image.size.height / image.size.width
        let size = CGSize(width: screenSize.width, height: heightFactor * screenSize.width + 160)
            
        return size
    }
    
    func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                      withReuseIdentifier: "profileTopBar",
                                                                      forIndexPath: indexPath) as! ProfileCollectionReusableView
        headerView.achievementCount.text = String(userAchievementCount) + "st"
        headerView.score.text = String(userScore) + "P"
        headerView.followCount.text = String(userFollowsCount) + " Följer"
        headerView.followersCount.text = String(userFollowersCount) + " Följare"
        headerView.userAvatar.image = userAvatar
        headerView.username.text = username
        return headerView
    }
    
    @IBAction func pressCommentButton(sender: AnyObject?) {
        self.performSegueWithIdentifier("showCommentsFromProfile", sender: sender)
    }
    
    @IBAction func showLikes(sender: AnyObject?) {
        self.performSegueWithIdentifier("showLikesFromProfile", sender: sender)
    }
    
    @IBAction func showAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAchievementFromProfile", sender: sender)
    }
    
    @IBAction func followUser(sender: UIButton) {
        if sender.titleForState(.Normal) == "Följ" {
            sender.setTitle("Sluta följ", forState: .Normal)
        } else {
            sender.setTitle("Följ", forState: .Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        let cellIndex: Int
        if (sender!.tag != nil) {
            cellIndex = sender!.tag
        } else {
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            let thisCell: CollectionViewCell = main as! CollectionViewCell
            cellIndex = thisCell.tag
        }
        if segue.identifier == "showCommentsFromProfile" {
            let vc = segue.destinationViewController as! NewViewController
            vc.postId = postIds[cellIndex]
        }
        if segue.identifier == "showLikesFromProfile" {
            let vc = segue.destinationViewController as! LikesViewController
            vc.typeIs = "post"
            vc.postId = postIds[cellIndex]
        }
        if segue.identifier == "showAchievementFromProfile" {
            let vc = segue.destinationViewController as! ShowAchievementViewController
            vc.achievementId = achievementIds[cellIndex]
        }
    }

    func fetchDataFromUrlToPostImages(fetchUrl: String) {
        let url = NSURL(string: "http://192.168.1.116:3000" + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.postImages.append(image!)
    }
    
    func fetchDataFromUrlToUserAvatar(fetchUrl: String) {
        let url = NSURL(string: "http://192.168.1.116:3000" + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.userAvatar = image
    }
    
}
