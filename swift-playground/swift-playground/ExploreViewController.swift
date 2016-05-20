//
//  ExploreViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 12/02/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

@available(iOS 9.0, *)
class ExploreViewController: UIViewController, PostServiceDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Setup
    let postService = PostService()
    let achievementService = AchievementService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var collectionView: UICollectionView!
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    let likeActiveImage = UIImage(named: "heart-icon-active")
    let likeInactiveImage = UIImage(named: "heart-icon-inactive")
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
            postService.fetchMoreExplorePosts(postIds.last!)
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
        postService.getExplorePosts()
        searchField.layer.frame = CGRectMake(0 , 0, screenSize.width - 80, 30)
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("exploreCell", forIndexPath: indexPath) as! PostsCollectionViewCell
        
        let likesTapGesture = UITapGestureRecognizer(target: self, action: #selector(showLikes(_:)))
        let commentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(pressCommentButton(_:)))
        let achievementTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievement(_:)))
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        let profileLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        // Should be changed cause gesture recognizers only apply once.
        // cell.likeCount.addGestureRecognizer(likesTapGesture)
        cell.likeImageView.addGestureRecognizer(likesTapGesture)
        // cell.commentCount.addGestureRecognizer(commentsTapGesture)
        cell.commentImageView.addGestureRecognizer(commentsTapGesture)
        cell.label.addGestureRecognizer(achievementTapGesture)
        cell.profileImage.addGestureRecognizer(profileImageTapGesture)
        cell.profileLabel.addGestureRecognizer(profileLabelTapGesture)
        cell.profileImage.image = self.postUserAvatars[indexPath.row]
        cell.profileLabel.text! = self.postUserNames[indexPath.row]
        cell.imageView?.image = self.postImages[indexPath.row]
        cell.label?.text = self.achievementDescriptions[indexPath.row]
        cell.commentCount.text! = String(self.postCommentCounts[indexPath.row])
        cell.likeCount.text! = String(self.postLikeCounts[indexPath.row])
        cell.scoreLabel.text! = String(self.achievementScores[indexPath.row]) + "p"
        cell.commentButton?.tag = indexPath.row
        cell.commentCount?.tag = indexPath.row
        cell.moreButton?.tag = indexPath.row
        cell.postId = postIds[indexPath.row]
        if postLike[indexPath.row] {
            cell.likeButton?.setImage(likeActiveImage, forState: .Normal)
        } else {
            cell.likeButton?.setImage(likeInactiveImage, forState: .Normal)
        }
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
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
    
    // MARK: User Interaction
    @IBAction func pressCommentButton(sender: AnyObject?) {
        self.performSegueWithIdentifier("showCommentsFromExplore", sender: sender)
    }
    
    @IBAction func showLikes(sender: AnyObject?) {
        self.performSegueWithIdentifier("showLikesFromExplore", sender: sender)
    }
    
    @IBAction func showAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAchievementFromExplore", sender: sender)
    }
    
    @IBAction func showProfile(sender: AnyObject?) {
        self.performSegueWithIdentifier("showProfileFromExplore", sender: sender)
    }
    
    @IBAction func showSearch(sender: AnyObject) {
        self.performSegueWithIdentifier("showSearchFromExplore", sender: sender)
    }
    
    @IBAction func showMore(sender: AnyObject?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Visa uppdrag", style: UIAlertActionStyle.Default, handler: { action in
            self.performSegueWithIdentifier("showAchievementFromExplore", sender: sender)
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
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var cellIndex: Int
        if (sender!.tag != nil) {
            cellIndex = sender!.tag
            if segue.identifier == "showCommentsFromExplore" {
                let vc = segue.destinationViewController as! ShowPostViewController
                vc.postId = postIds[cellIndex]
            }
        } else {
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            let thisCell: PostsCollectionViewCell = main as! PostsCollectionViewCell
            cellIndex = thisCell.commentButton.tag
            if segue.identifier == "showCommentsFromExplore" {
                let vc = segue.destinationViewController as! ShowPostViewController
                vc.postId = thisCell.postId!
            }
        }
        
        if segue.identifier == "showLikesFromExplore" {
            let vc = segue.destinationViewController as! LikesViewController
            vc.typeIs = "post"
            vc.postId = postIds[cellIndex]
        }
        
        if segue.identifier == "showAchievementFromExplore" {
            let vc = segue.destinationViewController as! ShowAchievementViewController
            vc.achievementId = achievementIds[cellIndex]
        }
        
        if segue.identifier == "showProfileFromExplore" {
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
        //postVideoUrls.removeAtIndex(cellIndex)
        self.postUserIds.removeAtIndex(cellIndex)
        self.postUserNames.removeAtIndex(cellIndex)
        self.postUserAvatarUrls.removeAtIndex(cellIndex)
        self.postUserAvatars.removeAtIndex(cellIndex)
        self.postCommentCounts.removeAtIndex(cellIndex)
        self.postLikeCounts.removeAtIndex(cellIndex)
        self.postLike.removeAtIndex(cellIndex)
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    

    
}



