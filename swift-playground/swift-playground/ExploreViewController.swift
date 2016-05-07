//
//  ViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 12/02/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

@available(iOS 9.0, *)
class ExploreViewController: UIViewController, PostServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let postService = PostService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var collectionView: UICollectionView!
    
    var achievementDescriptions: [String] = []
    var achievementIds: [Int] = []
    var achievementScores: [Int] = []
    var postIds: [Int] = []
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
    
    func setPostData(json: AnyObject) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                achievementDescriptions.append((json[i]?["achievement_desc"])! as! String)
                achievementIds.append((json[i]?["achievement_id"]) as! Int)
                achievementScores.append(json[i]?["achievement_score"] as! Int)
                postIds.append(json[i]?["id"] as! Int)
                postImageUrls.append((json[i]?["image_url"])! as! String)
                // Handle null! postVideoUrls.append((json[i]?["video_url"])! as! String)
                postUserIds.append(json[i]?["user_id"] as! Int)
                postUserNames.append((json[i]?["user_name"])! as! String)
                postUserAvatarUrls.append((json[i]?["user_avatar_url"])! as! String)
                postCommentCounts.append(json[i]?["comments_count"] as! Int)
                postLikeCounts.append(json[i]?["likes_count"] as! Int)
                postLike.append(json[i]?["like"] as! Bool)
                
                fetchDataFromUrlToPostImages((json[i]?["image_url"])! as! String)
                fetchDataFromUrlToPostUserAvatars((json[i]?["user_avatar_url"])! as! String)
            }
        } else {
            morePostsToLoad = false
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    func updatePostData(json: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postService.getExplorePosts()
        self.postService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postIds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        loadMore(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("exploreCell", forIndexPath: indexPath) as! CollectionViewCell
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var cellIndex: Int
        if (sender!.tag != nil) {
            cellIndex = sender!.tag
        } else {
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            let thisCell: CollectionViewCell = main as! CollectionViewCell
            cellIndex = thisCell.commentButton.tag
        }
        
        if segue.identifier == "showCommentsFromExplore" {
            let vc = segue.destinationViewController as! NewViewController
            vc.postId = postIds[cellIndex]
        }
        
        if segue.identifier == "showAchievementFromExplore" {
            let vc = segue.destinationViewController as! ShowAchievementViewController
            vc.achievementId = achievementIds[cellIndex]
        }
        
        if segue.identifier == "showLikesFromExplore" {
            let vc = segue.destinationViewController as! LikesViewController
            vc.typeIs = "post"
            vc.postId = postIds[cellIndex]
        }
        
        if segue.identifier == "showProfileFromExplore" {
            let vc = segue.destinationViewController as! ProfileViewController
            vc.userId = postUserIds[cellIndex]
        }
        
    }
    
    
    func loadMore(cellIndex: Int) {
        if cellIndex == self.postIds.count - 1 && morePostsToLoad {
            postService.fetchMoreExplorePosts(postIds.last!)
        }
    }
    
    func fetchDataFromUrlToPostImages(fetchUrl: String) {
        let url = NSURL(string: "http://192.168.1.116:3000" + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.postImages.append(image!)
    }
    
    func fetchDataFromUrlToPostUserAvatars(fetchUrl: String) {
        let url = NSURL(string: "http://192.168.1.116:3000" + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.postUserAvatars.append(image!)
    }
    
}



