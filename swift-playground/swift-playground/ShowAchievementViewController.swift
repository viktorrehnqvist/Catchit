//
//  ShowAchievementViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 28/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import MobileCoreServices

class ShowAchievementViewController: UIViewController, AchievementServiceDelegate, UploadServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Setup
    let achievementService = AchievementService()
    let uploadService = UploadService()
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
    var segueShouldShowCompleters: Bool = false
    
    // MARK: Lifecycle
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
                    postUserIds.append(((json["completer_infos"] as! NSArray)[0] as! NSArray)[i] as! Int)
                    postUserNames.append(((json["completer_infos"] as! NSArray)[1] as! NSArray)[i] as! String)
                    postUserAvatarUrls.append(((json["completer_infos"] as! NSArray)[2] as! NSArray)[i] as! String)
                    postCommentCounts.append(json["posts"]!![i]?["comments_count"] as! Int)
                    postLikeCounts.append(json["posts"]!![i]?["likes_count"] as! Int)
                    
                    fetchDataFromUrlToPostImages(json["posts"]!![i]["image"]!!["url"]! as! String)
                    fetchDataFromUrlToPostUserAvatars(((json["completer_infos"] as! NSArray)[2] as! NSArray)[i] as! String)
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
    
    func updateAchievementsData(json: AnyObject) {
    }
    
    func setNewAchievementData(json: AnyObject) {
    }
    
    func setUploadedResult(json: AnyObject) {
        let postId = json["id"] as! Int
        self.performSegueWithIdentifier("showPostFromAchievement", sender: postId)
    }
    
    func loadMore(cellIndex: Int) {
        if cellIndex == self.postIds.count - 1 && morePostsToLoad {
            achievementService.fetchMorePostsForAchievement(postIds.last!, achievementId: achievementId)
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        achievementService.getAchievement(achievementId)
        self.uploadService.delegate = self
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
    
    // MARK: Layout
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postIds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        loadMore(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("showAchievementCell", forIndexPath: indexPath) as! PostsCollectionViewCell
        
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
        cell.postId = postIds[indexPath.row]
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
        headerView.uploadButton.layer.cornerRadius = 5
        header = headerView
        return headerView
    }
    
    // MARK: User Interaction
    @IBAction func bucketlistPress(sender: AnyObject?) {
        if header.bucketlistImage.image == addToBucketlistImage {
            achievementService.addToBucketlist(achievementId)
            header.bucketlistImage.image = removeFromBucketlistImage
        } else {
            achievementService.removeFromBucketlist(achievementId)
            header.bucketlistImage.image = addToBucketlistImage
        }
    }
    
    @IBAction func pressCommentButton(sender: AnyObject?) {
        self.performSegueWithIdentifier("showCommentsFromShowAchievement", sender: sender)
    }
    
    @IBAction func showCompleters(sender: AnyObject?) {
        self.segueShouldShowCompleters = true
        self.performSegueWithIdentifier("showLikesFromShowAchievement", sender: sender)
    }
    
    @IBAction func shareAchievement(sender: AnyObject?) {
        self.segueShouldShowCompleters = false
        self.performSegueWithIdentifier("showLikesFromShowAchievement", sender: sender)
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
        if mediaType!.isEqualToString(kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            let imageData: NSData = UIImagePNGRepresentation(image!)!
            uploadService.uploadImage(imageData, achievementId: achievementId)
        } else if mediaType!.isEqualToString(kUTTypeMovie as String) {
            let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL)!
            uploadService.uploadVideo(pickedVideo, achievementId: achievementId)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed.
        var cellIndex: Int = 0
        
        // This should be rewritten for better readability.
        if (sender!.tag != nil) {
            cellIndex = sender!.tag
        } else {
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            // If sender is a post.
            if let thisCell: PostsCollectionViewCell = main as? PostsCollectionViewCell {
                cellIndex = thisCell.commentButton.tag
                if segue.identifier == "showLikesFromShowAchievement" {
                    let vc = segue.destinationViewController as! LikesViewController
                    vc.typeIs = "post"
                    vc.postId = postIds[cellIndex]
                }
            } else {
                // If sender is an achievement.
                if let thisCell: AchievementsCollectionReusableView = mainCell as? AchievementsCollectionReusableView {
                    cellIndex = thisCell.tag
                    if segue.identifier == "showLikesFromShowAchievement" {
                        let vc = segue.destinationViewController as! LikesViewController
                        vc.achievementId = cellIndex
                        if segueShouldShowCompleters {
                            vc.typeIs = "achievementCompleters"
                        } else {
                            vc.typeIs = "achievementShare"
                        }
                    }
                }
            }
        }
        
        if segue.identifier == "showCommentsFromShowAchievement" {
            let vc = segue.destinationViewController as! ShowPostViewController
            vc.postId = postIds[cellIndex]
        }
        
        if segue.identifier == "showPostFromAchievement" {
            let vc = segue.destinationViewController as! ShowPostViewController
            vc.postId = sender!.integerValue
        }
    }
    
    // MARK: Additional Helpers
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
