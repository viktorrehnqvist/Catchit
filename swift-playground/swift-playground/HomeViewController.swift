//
//  HomeViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 12/02/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import AVKit
import AVFoundation

@available(iOS 9.0, *)
class HomeViewController: UIViewController, PostServiceDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Setup
    let postService = PostService()
    let achievementService = AchievementService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var collectionView: UICollectionView!
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    let likeActiveImage = UIImage(named: "heart-icon-active")
    let likeInactiveImage = UIImage(named: "heart-icon-inactive")
    var players: [AVPlayer] = []
    var playerLayers: [AVPlayerLayer] = []
    var activePlayer: AVPlayer?
    @IBOutlet weak var searchField: UITextField!
    
    var achievementDescriptions: [String] = []
    var achievementIds: [Int] = []
    var achievementScores: [Int] = []
    var postIds: [Int] = []
    var postCreatedAt: [String] = []
    var postUpdatedAt: [String] = []
    var postImageUrls: [String] = []
    var postImages: [UIImage] = []
    var postVideoUrls: [String] = []
    var postUserIds: [Int] = []
    var postUserNames: [String] = []
    var postUserAvatarUrls: [String] = []
    var postUserAvatars: [UIImage] = []
    var postCommentCounts: [Int] = []
    var postLikeCounts: [Int] = []
    var postLike: [Bool] = []
    var morePostsToLoad: Bool = true
    var justCheckedForNewPosts: Bool = true
    var activeCellIndexPath: NSIndexPath?
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: Lifecycle
    func setPostData(json: AnyObject) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                achievementDescriptions.append((json[i]?["achievement_desc"])! as! String)
                achievementIds.append((json[i]?["achievement_id"]) as! Int)
                achievementScores.append(json[i]?["achievement_score"] as! Int)
                postIds.append(json[i]?["id"] as! Int)
                postCreatedAt.append(json[i]?["created_at"] as! String)
                postUpdatedAt.append(json[i]?["updated_at"] as! String)
                postImageUrls.append((json[i]?["image_url"])! as! String)
                if ((json[i]?["video_url"] as? String) != nil) {
                    postVideoUrls.append(((json[i]?["video_url"]) as! String))
                    addNewPlayer(json[i]?["video_url"] as! String, shouldBeFirstInArray: false)
                } else {
                    postVideoUrls.append("")
                    addNewPlayer("", shouldBeFirstInArray: false)
                }
                postUserIds.append(json[i]?["user_id"] as! Int)
                postUserNames.append((json[i]?["user_name"])! as! String)
                postUserAvatarUrls.append((json[i]?["user_avatar_url"])! as! String)
                postCommentCounts.append(json[i]?["comments_count"] as! Int)
                postLikeCounts.append(json[i]?["likes_count"] as! Int)
                postLike.append(json[i]?["like"] as! Bool)
                
                fetchDataFromUrlToPostImages((json[i]?["image_url"])! as! String, new: false)
                fetchDataFromUrlToPostUserAvatars((json[i]?["user_avatar_url"])! as! String, new: false)
            }
        } else {
            morePostsToLoad = false
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    func updatePostData(json: AnyObject) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                if ((json[i]["deleted"] as? NSArray) != nil) {
                    for deletedPost in (json[i]["deleted"] as! NSArray) {
                        let deletedPostId = deletedPost.integerValue
                        let cellIndex = postIds.indexOf(deletedPostId)
                        destroyCell(cellIndex!)
                    }
                } else {
                    let postId = json[i]?["id"] as! Int
                    if let cellIndex = postIds.indexOf({$0 == postId}) {
                        achievementScores[cellIndex] = json[i]?["achievement_score"] as! Int
                        postUpdatedAt[cellIndex] = json[i]?["updated_at"] as! String
                        postCommentCounts[cellIndex] = json[i]?["comments_count"] as! Int
                        postLikeCounts[cellIndex] = json[i]?["likes_count"] as! Int
                        postLike[cellIndex] = json[i]?["like"] as! Bool
                    }
                }
                
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
        }
    }
    
    func setNewPostData(json: AnyObject) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                achievementDescriptions.insert(((json[i]?["achievement_desc"])! as! String), atIndex: 0)
                achievementIds.insert(((json[i]?["achievement_id"]) as! Int), atIndex: 0)
                achievementScores.insert((json[i]?["achievement_score"] as! Int), atIndex: 0)
                postIds.insert((json[i]?["id"] as! Int), atIndex: 0)
                postCreatedAt.insert((json[i]?["created_at"] as! String), atIndex: 0)
                postUpdatedAt.insert((json[i]?["updated_at"] as! String), atIndex: 0)
                postImageUrls.insert(((json[i]?["image_url"])! as! String), atIndex: 0)
                if ((json[i]?["video_url"] as? String) != nil) {
                    postVideoUrls.insert((json[i]?["video_url"] as! String), atIndex: 0)
                    addNewPlayer(json[i]?["video_url"] as! String, shouldBeFirstInArray: true)
                } else {
                    postVideoUrls.insert("", atIndex: 0)
                    addNewPlayer("", shouldBeFirstInArray: true)
                }
                postUserIds.insert((json[i]?["user_id"] as! Int), atIndex: 0)
                postUserNames.insert(((json[i]?["user_name"])! as! String), atIndex: 0)
                postUserAvatarUrls.insert(((json[i]?["user_avatar_url"])! as! String), atIndex: 0)
                postCommentCounts.insert((json[i]?["comments_count"] as! Int), atIndex: 0)
                postLikeCounts.insert((json[i]?["likes_count"] as! Int), atIndex: 0)
                postLike.insert((json[i]?["like"] as! Bool), atIndex: 0)
                
                fetchDataFromUrlToPostImages((json[i]?["image_url"])! as! String, new: true)
                fetchDataFromUrlToPostUserAvatars((json[i]?["user_avatar_url"])! as! String, new: true)
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
            playVideo(0)
        }
    }
    
    func loadMore(cellIndex: Int) {
        if cellIndex == self.postIds.count - 1 && morePostsToLoad {
            postService.fetchMoreHomePosts(postIds.last!)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if collectionView.contentOffset.y < -90.0 && justCheckedForNewPosts == false {
            postService.getNewHomePosts(postIds.first!)
            print(postIds.first)
            justCheckedForNewPosts = true
        }
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
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.layer.frame = CGRectMake(0 , 0, screenSize.width - 80, 30)
        self.postService.delegate = self
        self.collectionView.delegate = self
        postService.getHomePosts()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        postService.updatePosts(postIds, updatedAt: postUpdatedAt)
        justCheckedForNewPosts = false
        activePlayer?.play()
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
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
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PostsCollectionViewCell
            cell.imageView?.image = self.postImages[indexPath.row]
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as! PostsCollectionViewCell
            showVideo(cell, indexPath: indexPath)
            let videoTapGesture = UITapGestureRecognizer(target: self, action: #selector(videoToggleSound(_:)))
            cell.videoView.addGestureRecognizer(videoTapGesture)
        }
        
        let likeCountTapGesture = UITapGestureRecognizer(target: self, action: #selector(showLikes(_:)))
        let commentCountTapGesture = UITapGestureRecognizer(target: self, action: #selector(pressCommentButton(_:)))
        let likesTapGesture = UITapGestureRecognizer(target: self, action: #selector(showLikes(_:)))
        let commentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(pressCommentButton(_:)))
        let achievementTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievement(_:)))
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        let profileLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        // Should use button with image and label instead of multiple tapGestures
        cell.likeCount.addGestureRecognizer(likeCountTapGesture)
        cell.likeImageView.addGestureRecognizer(likesTapGesture)
        cell.commentCount.addGestureRecognizer(commentCountTapGesture)
        cell.commentImageView.addGestureRecognizer(commentsTapGesture)
        cell.label.addGestureRecognizer(achievementTapGesture)
        cell.profileImage.addGestureRecognizer(profileImageTapGesture)
        cell.profileLabel.addGestureRecognizer(profileLabelTapGesture)
        cell.profileImage.image = self.postUserAvatars[indexPath.row]
        cell.profileLabel.text! = self.postUserNames[indexPath.row]
        cell.label?.text = self.achievementDescriptions[indexPath.row]
        cell.commentCount.text! = String(self.postCommentCounts[indexPath.row])
        cell.likeCount.text! = String(self.postLikeCounts[indexPath.row])
        cell.scoreLabel.text! = "\(self.achievementScores[indexPath.row])p"
        cell.commentButton?.tag = indexPath.row
        cell.commentCount?.tag = indexPath.row
        cell.moreButton?.tag = indexPath.row
        cell.postId = postIds[indexPath.row]
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.tag = indexPath.row
        
        if postLike[indexPath.row] {
            cell.likeButton?.setImage(likeActiveImage, forState: .Normal)
        } else {
            cell.likeButton?.setImage(likeInactiveImage, forState: .Normal)
        }
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size: CGSize = CGSize(width: 0, height: 0)
        
        let image = self.postImages[indexPath.row]
        var height = image.size.height
        if image.size.width > screenSize.width {
            let resizeFactor = screenSize.width / image.size.width
            height = resizeFactor * image.size.height
        }
        size = CGSize(width: screenSize.width, height: height + 180)
        
        return size
    }
    
    // MARK: User Interaction
    @IBAction func pressCommentButton(sender: AnyObject?) {
        self.performSegueWithIdentifier("showCommentsFromHome", sender: sender)
    }
    
    @IBAction func showLikes(sender: AnyObject?) {
        self.performSegueWithIdentifier("showLikesFromHome", sender: sender)
    }
    
    @IBAction func showAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAchievementFromHome", sender: sender)
    }
    
    @IBAction func showProfile(sender: AnyObject?) {
        self.performSegueWithIdentifier("showProfileFromHome", sender: sender)
    }
    
    @IBAction func showSearch(sender: AnyObject) {
        self.performSegueWithIdentifier("showSearchFromHome", sender: sender)
    }
    
    @IBAction func showMore(sender: AnyObject?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Visa uppdrag", style: UIAlertActionStyle.Default, handler: { action in
            self.performSegueWithIdentifier("showAchievementFromHome", sender: sender)
        }))
        alert.addAction(UIAlertAction(title: "Lägg till uppdrag i min lista", style: UIAlertActionStyle.Default, handler: { action in
            self.achievementService.addToBucketlist(self.achievementIds[sender!.tag])
        }))
        if postUserIds[sender!.tag] == userDefaults.objectForKey("id")?.integerValue {
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
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        activePlayer?.pause()
        let cellIndex: Int
        if (sender!.tag != nil) {
            cellIndex = sender!.tag
            if segue.identifier == "showCommentsFromHome" {
                let vc = segue.destinationViewController as! ShowPostViewController
                vc.postId = postIds[cellIndex]
            }
        } else {
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            let thisCell: PostsCollectionViewCell = main as! PostsCollectionViewCell
            cellIndex = thisCell.commentButton.tag
            if segue.identifier == "showCommentsFromHome" {
                let vc = segue.destinationViewController as! ShowPostViewController
                vc.postId = thisCell.postId!
            }
        }
        
        if segue.identifier == "showLikesFromHome" {
            let vc = segue.destinationViewController as! LikesViewController
            vc.typeIs = "post"
            vc.postId = postIds[cellIndex]
        }
        
        if segue.identifier == "showAchievementFromHome" {
            let vc = segue.destinationViewController as! ShowAchievementViewController
            vc.achievementId = achievementIds[cellIndex]
        }
        
        if segue.identifier == "showProfileFromHome" {
            let vc = segue.destinationViewController as! ProfileViewController
            vc.userId = postUserIds[cellIndex]
        }
        
    }
    
    // MARK: Additional Helpers
    func fetchDataFromUrlToPostImages(fetchUrl: String, new: Bool) {
        let url = NSURL(string: self.url + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        if new {
            self.postImages.insert(image!, atIndex: 0)
        } else {
            self.postImages.append(image!)
        }
    }
    
    func fetchDataFromUrlToPostUserAvatars(fetchUrl: String, new: Bool) {
        let url = NSURL(string: self.url + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        if new {
            self.postUserAvatars.insert(image!, atIndex: 0)
        } else {
            self.postUserAvatars.append(image!)
        }
    }
    
    func destroyCell(cellIndex: Int) {
        self.achievementDescriptions.removeAtIndex(cellIndex)
        self.achievementIds.removeAtIndex(cellIndex)
        self.achievementScores.removeAtIndex(cellIndex)
        self.postIds.removeAtIndex(cellIndex)
        self.postCreatedAt.removeAtIndex(cellIndex)
        self.postUpdatedAt.removeAtIndex(cellIndex)
        self.postImageUrls.removeAtIndex(cellIndex)
        self.postImages.removeAtIndex(cellIndex)
        self.postVideoUrls.removeAtIndex(cellIndex)
        self.postUserIds.removeAtIndex(cellIndex)
        self.postUserNames.removeAtIndex(cellIndex)
        self.postUserAvatarUrls.removeAtIndex(cellIndex)
        self.postUserAvatars.removeAtIndex(cellIndex)
        self.postCommentCounts.removeAtIndex(cellIndex)
        self.postLikeCounts.removeAtIndex(cellIndex)
        self.postLike.removeAtIndex(cellIndex)
        self.players.removeAtIndex(cellIndex)
        self.playerLayers.removeAtIndex(cellIndex)
        let centerCellIndexPath = collectionView.centerCellIndexPath!.row
        if self.players.count > centerCellIndexPath {
            playVideo(centerCellIndexPath)
        } else {
            playVideo(postVideoUrls.endIndex - 1)
        }
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



