//
//  ProfileViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 22/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ProfileViewController: UIViewController, UserServiceDelegate, PostServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: Setup
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    let userService = UserService()
    let postService = PostService()
    let achievementService = AchievementService()
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    @IBOutlet weak var collectionView: UICollectionView!
    var header: ProfileCollectionReusableView!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let likeActiveImage = UIImage(named: "heart-icon-active")
    let likeInactiveImage = UIImage(named: "heart-icon-inactive")
    var players: [AVPlayer] = []
    var playerLayers: [AVPlayerLayer] = []
    var activePlayer: AVPlayer?
    var counter: Float = 0
    var timer = NSTimer()
    
    var userId: Int?
    var username: String?
    var userAvatar: UIImage?
    var userAvatarUrl: String?
    var userFollowed: Bool = false
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
    var totalAchievements: Int = 10
    var completeFactor: Float?
    var activeCellIndexPath: NSIndexPath?
    
    // MARK: Lifecycle
    func setUserData(json: AnyObject, follow: Bool) {
        username = json["name"] as? String
        userAchievementCount = json["achievement_count"] as! Int
        userScore = json["user_score"] as! Int
        userFollowsCount = (json["follow_infos"] as! NSArray)[0].count
        userFollowersCount = (json["follower_infos"] as! NSArray)[0].count
        userFollowed = json["follow"] as! Bool
        postLike = (json["like"] as! NSArray) as! [Bool]
        fetchDataFromUrlToUserAvatar((json["avatar_url"] as! String))
        if (json["posts"] as! NSArray).count > 0 {
            for i in 0...((json["posts"] as! NSArray).count - 1) {
                achievementDescriptions.append((json["achievements"] as! NSArray)[i]["description"] as! String)
                achievementIds.append((json["posts"] as! NSArray)[i]["achievement_id"] as! Int)
                achievementScores.append((json["achievements"] as! NSArray)[i]["score"] as! Int)
                postIds.append((json["posts"] as! NSArray)[i]["id"] as! Int)
                postImageUrls.append((json["posts"] as! NSArray)[i]["image"]!!["url"] as! String)
                if (((json["video_urls"] as! NSArray)[i] as? String) != nil) {
                    postVideoUrls.append(((json["video_urls"] as! NSArray)[i] as! String))
                    addNewPlayer((json["video_urls"] as! NSArray)[i] as! String, shouldBeFirstInArray: false)
                } else {
                    postVideoUrls.append("")
                    addNewPlayer("", shouldBeFirstInArray: false)
                }
                postCommentCounts.append((json["posts"] as! NSArray)[i]["comments_count"] as! Int)
                postLikeCounts.append((json["posts"] as! NSArray)[i]["likes_count"] as! Int)
                fetchDataFromUrlToPostImages((json["posts"] as! NSArray)[i]["image"]!!["url"] as! String)
            }
        } else {
            morePostsToLoad = false
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
        startTimer()
    }
    
    func updateUserData(json: AnyObject) {
        username = json["name"] as? String
        userAchievementCount = json["achievement_count"] as! Int
        userScore = json["user_score"] as! Int
        userFollowsCount = (json["follow_infos"] as! NSArray)[0].count
        userFollowersCount = (json["follower_infos"] as! NSArray)[0].count
        userFollowed = json["follow"] as! Bool
        fetchDataFromUrlToUserAvatar((json["avatar_url"] as! String))
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    func loadMore(cellIndex: Int) {
        if cellIndex == self.postIds.count - 1 && morePostsToLoad {
            postService.fetchMoreUserPosts(userId!, lastPostId: postIds.last!)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let centerCellIndexPath: NSIndexPath  = collectionView.centerCellIndexPath {
            if centerCellIndexPath != activeCellIndexPath {
                activeCellIndexPath = centerCellIndexPath
                NSNotificationCenter.defaultCenter().removeObserver(self)
                activePlayer?.muted = true
                activePlayer?.pause()
                playVideo(centerCellIndexPath.row)
            }
        }
    }
    
    func setPostData(json: AnyObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if json.count > 0 {
                for i in 0...(json.count - 1) {
                    self.achievementDescriptions.append((json[i]?["achievement_desc"])! as! String)
                    self.achievementIds.append((json[i]?["achievement_id"]) as! Int)
                    self.achievementScores.append(json[i]?["achievement_score"] as! Int)
                    self.postIds.append(json[i]?["id"] as! Int)
                    self.postImageUrls.append((json[i]?["image_url"])! as! String)
                    if ((json[i]?["video_url"] as? String) != nil) {
                        self.postVideoUrls.append(((json[i]?["video_url"]) as! String))
                        self.addNewPlayer(json[i]?["video_url"] as! String, shouldBeFirstInArray: false)
                    } else {
                        self.postVideoUrls.append("")
                        self.addNewPlayer("", shouldBeFirstInArray: false)
                    }
                    self.postCommentCounts.append(json[i]?["comments_count"] as! Int)
                    self.postLikeCounts.append(json[i]?["likes_count"] as! Int)
                    self.postLike.append(json[i]?["like"] as! Bool)
                    self.fetchDataFromUrlToPostImages((json[i]?["image_url"])! as! String)
                }
            } else {
                self.morePostsToLoad = false
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(self.collectionView.reloadData)
        })
    }
    
    func setNewPostData(json: AnyObject) {
    }
    
    func updatePostData(json: AnyObject) {
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if (userId != nil) {
            userService.getUserData(userId!)
        } else {
            // If no id is set, fetch current user
            userId = userDefaults.objectForKey("id")! as? Int
            userService.getCurrentUserData()
        }
        self.postService.delegate = self
        self.userService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        userService.updateUserData(userId!)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        activePlayer?.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postIds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        loadMore(indexPath.row)
        
        var cell: PostsCollectionViewCell!
        if postVideoUrls[indexPath.row] == "" {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("profileCell", forIndexPath: indexPath) as! PostsCollectionViewCell
            cell.imageView?.image = self.postImages[indexPath.row]
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("profileVideoCell", forIndexPath: indexPath) as! PostsCollectionViewCell
            showVideo(cell, indexPath: indexPath)
            let videoTapGesture = UITapGestureRecognizer(target: self, action: #selector(videoToggleSound(_:)))
            cell.videoView.addGestureRecognizer(videoTapGesture)
        }
        
        let likesTapGesture = UITapGestureRecognizer(target: self, action: #selector(showLikes(_:)))
        let commentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(pressCommentButton(_:)))
        let achievementTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievement(_:)))
        
        cell.tag = indexPath.row
        cell.profileImage.image = userAvatar
        cell.profileLabel.text = username
        cell.likeCount.addGestureRecognizer(likesTapGesture)
        cell.commentCount.addGestureRecognizer(commentsTapGesture)
        cell.label.addGestureRecognizer(achievementTapGesture)
        cell.commentCount.text! = String(postCommentCounts[indexPath.row])
        cell.likeCount.text! = String(postLikeCounts[indexPath.row])
        cell.scoreLabel.text! = "\(achievementScores[indexPath.row])p"
        cell.label?.text = self.achievementDescriptions[indexPath.row]
        if postLike[indexPath.row] {
            cell.likeButton?.setImage(likeActiveImage, forState: .Normal)
        } else {
            cell.likeButton?.setImage(likeInactiveImage, forState: .Normal)
        }
        cell.commentButton?.tag = indexPath.row
        cell.commentCount?.tag = indexPath.row
        cell.postId = postIds[indexPath.row]
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.tag = indexPath.row
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let image = self.postImages[indexPath.row]
        var height = image.size.height
        if image.size.width > screenSize.width {
            let resizeFactor = screenSize.width / image.size.width
            height = resizeFactor * image.size.height
        }
        let size = CGSize(width: screenSize.width, height: height + 180)
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                      withReuseIdentifier: "profileTopBar",
                                                                      forIndexPath: indexPath) as! ProfileCollectionReusableView
        headerView.achievementCount.text = "\(userAchievementCount)st"
        headerView.score.text = "\(userScore)P"
        headerView.followCount.text = "\(userFollowsCount) Följer"
        headerView.followersCount.text = "\(userFollowersCount) Följare"
        headerView.followCount.tag = userId!
        headerView.followersCount.tag = userId!
        headerView.userAvatar.image = userAvatar
        headerView.userAvatar.clipsToBounds = true
        headerView.userAvatar.contentMode = UIViewContentMode.ScaleToFill
        headerView.username.text = username
        headerView.completeLabel.text = "\(userAchievementCount)/\(totalAchievements)"
        
        if userId == userDefaults.objectForKey("id")?.integerValue {
            headerView.followButton.setTitle("Inställningar", forState: .Normal)
            let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(changeAvatar(_:)))
            headerView.userAvatar.addGestureRecognizer(profileTapGesture)
        }
        
        if self.userFollowed {
            headerView.followButton.setTitle("Sluta följ", forState: .Normal)
        }
        
        header = headerView
        return headerView
    }
    
    // MARK: User Interaction
    @IBAction func pressCommentButton(sender: AnyObject?) {
        self.performSegueWithIdentifier("showCommentsFromProfile", sender: sender)
    }
    
    @IBAction func showLikes(sender: AnyObject?) {
        self.performSegueWithIdentifier("showLikesFromProfile", sender: sender)
    }
    
    @IBAction func showAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAchievementFromProfile", sender: sender)
    }
    
    @IBAction func showFollowsFromProfile(sender: AnyObject) {
        self.performSegueWithIdentifier("showFollowsFromProfile", sender: sender)
    }
    
    @IBAction func showFollowersFromProfile(sender: AnyObject) {
        self.performSegueWithIdentifier("showFollowersFromProfile", sender: sender)
    }
    
    @IBAction func followUser(sender: UIButton) {
        if sender.titleForState(.Normal) == "Följ" {
            userService.followUserChange(userId!, follow: true)
            sender.setTitle("Sluta följ", forState: .Normal)
            self.userFollowed = true
            self.userFollowersCount += 1
        } else if sender.titleForState(.Normal) == "Sluta följ" {
            userService.followUserChange(userId!, follow: false)
            sender.setTitle("Följ", forState: .Normal)
            userFollowed = false
            self.userFollowersCount -= 1
        } else {
            self.performSegueWithIdentifier("showSettingsFromProfile", sender: sender)
        }
        header.followersCount.text = "\(userFollowersCount) Följare"
    }
    
    @IBAction func showMore(sender: AnyObject?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Visa uppdrag", style: UIAlertActionStyle.Default, handler: { action in
            self.performSegueWithIdentifier("showAchievementFromProfile", sender: sender)
        }))
        if userId == userDefaults.objectForKey("id")?.integerValue {
            alert.addAction(UIAlertAction(title: "Radera inlägg", style: UIAlertActionStyle.Destructive, handler: { action in
                self.postService.destroyPost(self.postIds[sender!.tag])
                self.destroyCell(sender!.tag)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Rapportera inlägg", style: UIAlertActionStyle.Destructive, handler: nil))
        }
        alert.addAction(UIAlertAction(title: "Avbryt", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func videoToggleSound(sender: AnyObject?) {
        let point = sender?.view
        let mainCell = point?.superview
        let main = mainCell?.superview
        let thisCell: PostsCollectionViewCell = main as! PostsCollectionViewCell
        let player = players[thisCell.tag]
        player.muted = !player.muted
    }
    
    @IBAction func changeAvatar(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAvatarFromProfile", sender: sender)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        activePlayer?.pause()
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        var cellIndex: Int?
        if (sender!.tag != nil) {
            cellIndex = sender!.tag
        } else {
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            if let thisCell: PostsCollectionViewCell = main as? PostsCollectionViewCell {
                cellIndex = thisCell.tag
            }
        }
        
        if segue.identifier == "showCommentsFromProfile" {
            let vc = segue.destinationViewController as! ShowPostViewController
            vc.postId = postIds[cellIndex!]
        }
        
        if segue.identifier == "showLikesFromProfile" {
            let vc = segue.destinationViewController as! LikesViewController
            if cellIndex != nil {
                vc.typeIs = "post"
                vc.postId = postIds[cellIndex!]
            }
        }
        
        if segue.identifier == "showAchievementFromProfile" {
            let vc = segue.destinationViewController as! ShowAchievementViewController
            vc.achievementId = achievementIds[cellIndex!]
        }
        
        if segue.identifier == "showFollowsFromProfile" {
            let vc = segue.destinationViewController as! LikesViewController
            vc.typeIs = "follows"
            vc.userId = userId
        }
        
        if segue.identifier == "showFollowersFromProfile" {
            let vc = segue.destinationViewController as! LikesViewController
            vc.typeIs = "followers"
            vc.userId = userId
        }
    }
    
    // MARK: Additional Helpers
    func fetchDataFromUrlToPostImages(fetchUrl: String) {
        let url = NSURL(string: self.url + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.postImages.append(image!)
    }
    
    func fetchDataFromUrlToUserAvatar(fetchUrl: String) {
        let url = NSURL(string: self.url + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.userAvatar = image
    }
    

    func startTimer() {
        if userAchievementCount > 0 {
            completeFactor = Float(userAchievementCount) / Float(totalAchievements)
            timer = NSTimer.scheduledTimerWithTimeInterval(0.005, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    func timerAction() {
        counter += 0.002
        header.completeProgressView.progress = counter
        if completeFactor < counter {
            timer.invalidate()
            return
        }
    }
    
    func destroyCell(cellIndex: Int) {
        self.userScore -= achievementScores[cellIndex]
        self.userAchievementCount -= 1
        header.completeProgressView.progress = Float(userAchievementCount) / Float(totalAchievements)
        self.achievementDescriptions.removeAtIndex(cellIndex)
        self.achievementIds.removeAtIndex(cellIndex)
        self.achievementScores.removeAtIndex(cellIndex)
        self.postIds.removeAtIndex(cellIndex)
        self.postImageUrls.removeAtIndex(cellIndex)
        self.postImages.removeAtIndex(cellIndex)
        self.postVideoUrls.removeAtIndex(cellIndex)
        self.postCommentCounts.removeAtIndex(cellIndex)
        self.postLikeCounts.removeAtIndex(cellIndex)
        self.postLike.removeAtIndex(cellIndex)
        self.players.removeAtIndex(cellIndex)
        self.playerLayers.removeAtIndex(cellIndex)
        playVideo(collectionView.centerCellIndexPath!.row)
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    func showVideo(cell: PostsCollectionViewCell, indexPath: NSIndexPath) {
        let image = self.postImages[indexPath.row]
        let resizeFactor = screenSize.width / image.size.width
        let playerLayer = playerLayers[indexPath.row]
        playerLayer.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: image.size.height * resizeFactor)
        cell.videoView.layer.sublayers = [playerLayer]
    }
    
    func playVideo(index: Int) {
        if !postVideoUrls.isEmpty && postVideoUrls[index] != "" {
            activePlayer = players[index]
            activePlayer!.play()
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(playerItemDidReachEnd(_:)),
                                                             name: AVPlayerItemDidPlayToEndTimeNotification,
                                                             object: self.activePlayer!.currentItem)
        }
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.activePlayer!.seekToTime(kCMTimeZero)
        self.activePlayer!.play()
    }
    
    func addNewPlayer(urlString: String, shouldBeFirstInArray: Bool) {
        let player = AVPlayer(URL: NSURL(string: url + urlString)!)
        player.muted = true
        let playerLayer = AVPlayerLayer(player: player)
        if shouldBeFirstInArray {
            players.insert(player, atIndex: 0)
            playerLayers.insert(playerLayer, atIndex: 0)
        } else {
            players.append(player)
            playerLayers.append(playerLayer)
        }
    }
    
}
