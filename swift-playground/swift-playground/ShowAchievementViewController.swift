//
//  ShowAchievementViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 28/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import MobileCoreServices

class ShowAchievementViewController: UIViewController, AchievementServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let achievementService = AchievementService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var collectionView: UICollectionView!
    var header: AchievementsCollectionReusableView!
    
    let addToBucketlistImage = UIImage(named: "achievement_button_icon3")
    let removeFromBucketlistImage = UIImage(named: "bucketlist-remove_icon")
    var achievementDescription: String!
    var achievementId: Int!
    var achievementScore: Int = 0
    var achievementCompleterCount: Int = 0
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
    var morePostsToLoad: Bool = true
    
    
    func setAchievementData(json: AnyObject, firstFetch: Bool) {
        if firstFetch {
            achievementScore = json["score"] as! Int
            achievementCompleterCount = json["posts"]!!.count
            achievementDescription = json["description"] as! String
            if json["posts"]!!.count > 0 {
                // Prevent loading more than 4 posts initially.
                var jsonCountMaxFourPosts: Int!
                if json["posts"]!!.count > 4 {
                    jsonCountMaxFourPosts = 4
                } else {
                    jsonCountMaxFourPosts = json["posts"]!!.count
                }
                for i in 0...(jsonCountMaxFourPosts - 1) {
                    postIds.append(json["posts"]!![i]?["id"] as! Int)
                    postImageUrls.append((json["posts"]!![i]["image"]!!["url"])! as! String)
                    // Handle null! postVideoUrls.append((json[i]?["video_url"])! as! String)
                    postUserIds.append(json["completer_infos"]!![0][i] as! Int)
                    postUserNames.append(json["completer_infos"]!![1][i] as! String)
                    postUserAvatarUrls.append(json["completer_infos"]!![2][i] as! String)
                    postCommentCounts.append(json["posts"]!![i]?["comments_count"] as! Int)
                    postLikeCounts.append(json["posts"]!![i]?["likes_count"] as! Int)
                    
                    fetchDataFromUrlToPostImages(json["posts"]!![i]["image"]!!["url"]! as! String)
                    fetchDataFromUrlToPostUserAvatars(json["completer_infos"]!![2][i]! as! String)
                }
            } else {
                morePostsToLoad = false
            }
        } else {
            if json.count > 0 {
                for i in 0...(json.count - 1) {
                    print(json)
                    postIds.append(json[i]?["id"] as! Int)
                    postImageUrls.append((json[i]?["image_url"])! as! String)
                    // Handle null! postVideoUrls.append((json[i]?["video_url"])! as! String)
                    postUserIds.append(json[i]?["user_id"] as! Int)
                    postUserNames.append((json[i]?["user_name"])! as! String)
                    postUserAvatarUrls.append((json[i]?["user_avatar_url"])! as! String)
                    postCommentCounts.append(json[i]?["comments_count"] as! Int)
                    postLikeCounts.append(json[i]?["likes_count"] as! Int)
                    
                    fetchDataFromUrlToPostImages((json[i]?["image_url"])! as! String)
                    fetchDataFromUrlToPostUserAvatars((json[i]?["user_avatar_url"])! as! String)
                }
            } else {
                morePostsToLoad = false
            }

        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        achievementService.getAchievement(achievementId)
        self.achievementService.delegate = self
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
        
        loadMore(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("showAchievementCell", forIndexPath: indexPath) as! CollectionViewCell
        
        let likesTapGesture = UITapGestureRecognizer(target: self, action: #selector(ShowAchievementViewController.showLikes(_:)))
        let commentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(ShowAchievementViewController.pressCommentButton(_:)))
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        let profileLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        cell.tag = indexPath.row
        cell.likeCount.addGestureRecognizer(likesTapGesture)
        cell.commentCount.addGestureRecognizer(commentsTapGesture)
        cell.profileImage.addGestureRecognizer(profileImageTapGesture)
        cell.profileLabel.addGestureRecognizer(profileLabelTapGesture)
        cell.imageView?.image = postImages[indexPath.row]
        cell.label?.text = achievementDescription
        cell.scoreLabel.text = String(achievementScore) + "p"
        cell.likeCount.text = String(postLikeCounts[indexPath.row]) + " gilla-markeringar"
        cell.commentCount.text = String(postCommentCounts[indexPath.row]) + " kommentarer"
        cell.profileImage.image = postUserAvatars[indexPath.row]
        cell.profileLabel.text = postUserNames[indexPath.row]
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
                                                                               forIndexPath: indexPath) as! AchievementsCollectionReusableView
        let bucketlistImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(bucketlistPress(_:)))
        headerView.bucketlistImage.addGestureRecognizer(bucketlistImageTapGesture)
        headerView.achievementDescription.text = achievementDescription
        headerView.achievementCompleterCount.text = String(achievementCompleterCount) + " har klarat detta"
        headerView.achievementScore.text = String(achievementScore) + "p"
        headerView.tag = achievementId
        header = headerView
        return headerView
    }
    
    
    @IBAction func bucketlistPress(sender: AnyObject?) {
        // Check for better compare method, without string comparing
        if header.bucketlistImage.image == UIImage(named: "achievement_button_icon3") {
            header.bucketlistImage.image = UIImage(named: "bucketlist-remove_icon")
        } else {
            header.bucketlistImage.image = UIImage(named: "achievement_button_icon3")
        }
    }
    
    @IBAction func pressCommentButton(sender: AnyObject?) {
        self.performSegueWithIdentifier("showCommentsFromShowAchievement", sender: sender)
    }
    
    @IBAction func showLikes(sender: AnyObject?) {
        self.performSegueWithIdentifier("showLikesFromShowAchievement", sender: sender)
    }
    
    @IBAction func showProfile(sender: AnyObject?) {
        self.performSegueWithIdentifier("showProfileFromShowAchievement", sender: sender)
    }
    
    @IBAction func followUser(sender: UIButton) {
        if sender.titleForState(.Normal) == "Följ" {
            sender.setTitle("Sluta följ", forState: .Normal)
        } else {
            sender.setTitle("Följ", forState: .Normal)
        }
    }
    
    @IBAction func uploadPost(sender: AnyObject?) {
        let existingOrNewMediaController = UIAlertController(title: "Inlägg", message: "Välj från bibliotek eller ta bild", preferredStyle: .Alert)
        existingOrNewMediaController.addAction(UIAlertAction(title: "Välj från bibliotek", style: .Default) { (UIAlertAction) in
            self.useLibrary()
            })
        existingOrNewMediaController.addAction(UIAlertAction(title: "Ta bild eller video", style: .Default) { (UIAlertAction) in
            self.useCamera()
            })
        existingOrNewMediaController.addAction(UIAlertAction(title: "Avbryt", style: .Cancel, handler: nil))
        self.presentViewController(existingOrNewMediaController, animated: true, completion: nil)
    }
    
    func useLibrary() {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        imageFromSource.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imageFromSource.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        self.presentViewController(imageFromSource, animated: true, completion: nil)
    }
    
    func useCamera() {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        imageFromSource.sourceType = UIImagePickerControllerSourceType.Camera
        imageFromSource.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        self.presentViewController(imageFromSource, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType]
        var image: UIImage?
        var videoUrl: String?
        if mediaType!.isEqualToString(kUTTypeImage as String) {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        } else if mediaType!.isEqualToString(kUTTypeMovie as String) {
            videoUrl = info[UIImagePickerControllerMediaURL] as? String
        }
        print(image)
        print(videoUrl)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed.
        let cellIndex: Int
        
        // This should be rewritten for better readability.
        if (sender!.tag != nil) {
            cellIndex = sender!.tag
        } else {
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            // If sender is a post.
            if let thisCell: CollectionViewCell = main as? CollectionViewCell {
                cellIndex = thisCell.commentButton.tag
                if segue.identifier == "showLikesFromShowAchievement" {
                    let vc = segue.destinationViewController as! LikesViewController
                    vc.typeIsPost = true
                    vc.postId = postIds[cellIndex]
                }
            } else {
                // If sender is an achievement.
                let thisCell: AchievementsCollectionReusableView = mainCell as! AchievementsCollectionReusableView
                cellIndex = thisCell.tag
                if segue.identifier == "showLikesFromShowAchievement" {
                    let vc = segue.destinationViewController as! LikesViewController
                    vc.typeIsPost = false
                    vc.achievementId = cellIndex
                }
            }
        }
        
        if segue.identifier == "showCommentsFromShowAchievement" {
            let vc = segue.destinationViewController as! NewViewController
            vc.postId = postIds[cellIndex]
        }
    }
    
    func fetchDataFromUrlToPostImages(fetchUrl: String) {
        let url = NSURL(string: "http://localhost:3000" + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.postImages.append(image!)
    }
    
    func fetchDataFromUrlToPostUserAvatars(fetchUrl: String) {
        let url = NSURL(string: "http://localhost:3000" + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.postUserAvatars.append(image!)
    }
    
    func loadMore(cellIndex: Int) {
        if cellIndex == self.postIds.count - 1 && morePostsToLoad {
            achievementService.fetchMorePostsForAchievement(postIds.last!, achievementId: achievementId)
        }
    }
    
}
