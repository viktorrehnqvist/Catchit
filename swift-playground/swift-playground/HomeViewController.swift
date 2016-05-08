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

@available(iOS 9.0, *)
class HomeViewController: UIViewController, PostServiceDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Setup
    let postService = PostService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var collectionView: UICollectionView!
    
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
                // Handle null! postVideoUrls.append((json[i]?["video_url"])! as! String)
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
        print(json)
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                let postId = json[i]?["id"] as! Int
                if let cellIndex = postIds.indexOf({$0 == postId}) {
                    achievementScores[cellIndex] = json[i]?["achievement_score"] as! Int
                    postUpdatedAt[cellIndex] = json[i]?["updated_at"] as! String
                    postCommentCounts[cellIndex] = json[i]?["comments_count"] as! Int
                    postLikeCounts[cellIndex] = json[i]?["likes_count"] as! Int
                    postLike[cellIndex] = json[i]?["like"] as! Bool
                }

            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
        }
    }
    
    func setNewPostData(json: AnyObject) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                print(json)
                achievementDescriptions.insert(((json[i]?["achievement_desc"])! as! String), atIndex: 0)
                achievementIds.insert(((json[i]?["achievement_id"]) as! Int), atIndex: 0)
                achievementScores.insert((json[i]?["achievement_score"] as! Int), atIndex: 0)
                postIds.insert((json[i]?["id"] as! Int), atIndex: 0)
                postCreatedAt.insert((json[i]?["created_at"] as! String), atIndex: 0)
                postUpdatedAt.insert((json[i]?["updated_at"] as! String), atIndex: 0)
                postImageUrls.insert(((json[i]?["image_url"])! as! String), atIndex: 0)
                // Handle null! postVideoUrls.append((json[i]?["video_url"])! as! String)
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
        }
    }
    
    func loadMore(cellIndex: Int) {
        if cellIndex == self.postIds.count - 1 && morePostsToLoad {
            postService.fetchMorePosts(postIds.last!)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if collectionView.contentOffset.y < -90.0 && justCheckedForNewPosts == false {
            postService.getNewPosts(postIds.first!)
            justCheckedForNewPosts = true
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        postService.getPosts()
        self.postService.delegate = self
        self.collectionView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        postService.updatePosts(postIds, updatedAt: postUpdatedAt)
        justCheckedForNewPosts = false
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PostsCollectionViewCell
        
        let likesTapGesture = UITapGestureRecognizer(target: self, action: #selector(showLikes(_:)))
        let commentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(pressCommentButton(_:)))
        let achievementTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievement(_:)))
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        let profileLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        cell.likeCount.addGestureRecognizer(likesTapGesture)
        cell.commentCount.addGestureRecognizer(commentsTapGesture)
        cell.label.addGestureRecognizer(achievementTapGesture)
        cell.profileImage.addGestureRecognizer(profileImageTapGesture)
        cell.profileLabel.addGestureRecognizer(profileLabelTapGesture)
        cell.profileImage.image = self.postUserAvatars[indexPath.row]
        cell.profileLabel.text! = self.postUserNames[indexPath.row]
        cell.imageView?.image = self.postImages[indexPath.row]
        cell.label?.text = self.achievementDescriptions[indexPath.row]
        cell.commentCount.text! = String(self.postCommentCounts[indexPath.row]) + " kommentarer"
        cell.likeCount.text! = String(self.postLikeCounts[indexPath.row]) + " gilla-markeringar"
        cell.scoreLabel.text! = String(self.achievementScores[indexPath.row]) + "p"
        cell.commentButton?.tag = indexPath.row
        cell.commentCount?.tag = indexPath.row
        cell.postId = postIds[indexPath.row]
        if postLike[indexPath.row] {
            cell.likeButton?.setTitle("Sluta gilla", forState: .Normal)
        } else {
            cell.likeButton?.setTitle("Gilla", forState: .Normal)
        }
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
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
        let url = NSURL(string: "http://192.168.1.116:3000" + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        if new {
            self.postImages.insert(image!, atIndex: 0)
        } else {
            self.postImages.append(image!)
        }
    }
    
    func fetchDataFromUrlToPostUserAvatars(fetchUrl: String, new: Bool) {
        let url = NSURL(string: "http://192.168.1.116:3000" + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        if new {
            self.postUserAvatars.insert(image!, atIndex: 0)
        } else {
            self.postUserAvatars.append(image!)
        }
    }
    
}



