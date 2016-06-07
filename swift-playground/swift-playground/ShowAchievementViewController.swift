//
//  ShowAchievementViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 28/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation

class ShowAchievementViewController: UIViewController, AchievementServiceDelegate, UploadServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Setup
    
    let achievementService = AchievementService()
    let uploadService = UploadService()
    let postService = PostService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    let userDefaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var collectionView: UICollectionView!
    var players: [AVPlayer] = []
    var playerLayers: [AVPlayerLayer] = []
    var activePlayer: AVPlayer?
    var header: AchievementsCollectionReusableView!
    
    let likeActiveImage = UIImage(named: "heart-icon-active")
    let likeInactiveImage = UIImage(named: "heart-icon-inactive")
    let addToBucketlistImage = UIImage(named: "achievement_button_icon3")
    let removeFromBucketlistImage = UIImage(named: "bucketlist-remove_icon")
    let unlockedIcon = UIImage(named: "unlocked_icon")
    
    var achievementDescription: String!
    var achievementId: Int!
    var achievementScore: Int = 0
    var achievementCompleterCount: Int = 0
    var achievementInBucketlist: Bool = false
    var achievementCompleted: Bool = false
    var achievementCompletedPostId: Int = 0
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
    var segueShouldShowCompleters: Bool = false
    var shouldRefresh: Bool = false
    var newUpload: Bool = false
    var activeCellIndexPath: NSIndexPath?
    
    // MARK: Lifecycle
    func setAchievementData(json: AnyObject, firstFetch: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if firstFetch {
                self.achievementInBucketlist = json["bucketlist"] as! Bool
                self.achievementCompleted = json["completed"] as! Bool
                self.achievementCompletedPostId = json["post_id"] as! Int
                self.achievementScore = json["score"] as! Int
                self.achievementCompleterCount = json["posts"]!!.count
                self.achievementDescription = json["description"] as! String
                if json["posts"]!!.count > 0 {
                    // Prevent loading more than 4 posts initially.
                    var jsonCountMaxFourPosts: Int!
                    if json["posts"]!!.count > 4 {
                        jsonCountMaxFourPosts = 4
                    } else {
                        jsonCountMaxFourPosts = json["posts"]!!.count
                    }
                    for i in 0...(jsonCountMaxFourPosts - 1) {
                        self.postIds.append(json["posts"]!![i]?["id"] as! Int)
                        self.postImageUrls.append((json["posts"]!![i]["image"]!!["url"])! as! String)
                        if (((json["video_urls"] as! NSArray)[i] as? String) != nil) {
                            self.postVideoUrls.append(((json["video_urls"] as! NSArray)[i] as! String))
                            self.addNewPlayer(((json["video_urls"] as! NSArray)[i] as! String), shouldBeFirstInArray: false)
                        } else {
                            self.postVideoUrls.append("")
                            self.addNewPlayer("", shouldBeFirstInArray: false)
                        }
                        self.postUserIds.append(((json["completer_infos"] as! NSArray)[0] as! NSArray)[i] as! Int)
                        self.postUserNames.append(((json["completer_infos"] as! NSArray)[1] as! NSArray)[i] as! String)
                        self.postUserAvatarUrls.append(((json["completer_infos"] as! NSArray)[2] as! NSArray)[i] as! String)
                        self.postCommentCounts.append(json["posts"]!![i]?["comments_count"] as! Int)
                        self.postLikeCounts.append(json["posts"]!![i]?["likes_count"] as! Int)
                        self.postLike.append((json["like"] as! NSArray)[i] as! Bool)
                        
                        self.fetchDataFromUrlToPostImages(json["posts"]!![i]["image"]!!["url"]! as! String)
                        self.fetchDataFromUrlToPostUserAvatars(((json["completer_infos"] as! NSArray)[2] as! NSArray)[i] as! String)
                    }
                } else {
                    self.morePostsToLoad = false
                }
            } else {
                if json.count > 0 {
                    for i in 0...(json.count - 1) {
                        self.postIds.append(json[i]?["id"] as! Int)
                        self.postImageUrls.append((json[i]?["image_url"])! as! String)
                        if ((json[i]?["video_url"] as? String) != nil) {
                            self.postVideoUrls.append(((json[i]?["video_url"]) as! String))
                            self.addNewPlayer(json[i]?["video_url"] as! String, shouldBeFirstInArray: false)
                        } else {
                            self.postVideoUrls.append("")
                            self.addNewPlayer("", shouldBeFirstInArray: false)
                        }
                        self.postUserIds.append(json[i]?["user_id"] as! Int)
                        self.postUserNames.append((json[i]?["user_name"])! as! String)
                        self.postUserAvatarUrls.append((json[i]?["user_avatar_url"])! as! String)
                        self.postCommentCounts.append(json[i]?["comments_count"] as! Int)
                        self.postLikeCounts.append(json[i]?["likes_count"] as! Int)
                        self.postLike.append((json["like"] as! NSArray)[i] as! Bool)
                        
                        self.fetchDataFromUrlToPostImages((json[i]?["image_url"])! as! String)
                        self.fetchDataFromUrlToPostUserAvatars((json[i]?["user_avatar_url"])! as! String)
                    }
                } else {
                    self.morePostsToLoad = false
                }
                
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(self.collectionView.reloadData)
        })
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
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        achievementService.getAchievement(achievementId)
        self.uploadService.delegate = self
        self.achievementService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.hidesBarsOnSwipe = false
        if shouldRefresh {
            newUpload = false
            refreshView()
        }
        
        if newUpload {
            shouldRefresh = true
        }
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
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("showAchievementCell", forIndexPath: indexPath) as! PostsCollectionViewCell
            cell.imageView?.image = self.postImages[indexPath.row]
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("showAchievementVideoCell", forIndexPath: indexPath) as! PostsCollectionViewCell
            showVideo(cell, indexPath: indexPath)
            let videoTapGesture = UITapGestureRecognizer(target: self, action: #selector(videoToggleSound(_:)))
            cell.videoView.addGestureRecognizer(videoTapGesture)
        }

        
        let likesTapGesture = UITapGestureRecognizer(target: self, action: #selector(ShowAchievementViewController.showLikes(_:)))
        let commentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(ShowAchievementViewController.pressCommentButton(_:)))
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        let profileLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        cell.tag = indexPath.row
        cell.likeCount.addGestureRecognizer(likesTapGesture)
        cell.commentCount.addGestureRecognizer(commentsTapGesture)
        cell.profileImage.addGestureRecognizer(profileImageTapGesture)
        cell.profileLabel.addGestureRecognizer(profileLabelTapGesture)
        cell.label?.text = achievementDescription
        cell.scoreLabel.text = "\(achievementScore)p"
        cell.likeCount.text = String(postLikeCounts[indexPath.row])
        cell.commentCount.text = String(postCommentCounts[indexPath.row])
        cell.profileImage.image = postUserAvatars[indexPath.row]
        cell.profileLabel.text = postUserNames[indexPath.row]
        cell.commentButton?.tag = indexPath.row
        cell.commentCount?.tag = indexPath.row
        if postLike[indexPath.row] {
            cell.likeButton?.setImage(likeActiveImage, forState: .Normal)
        } else {
            cell.likeButton?.setImage(likeInactiveImage, forState: .Normal)
        }
        cell.postId = postIds[indexPath.row]
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.tag = indexPath.row
        
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
    
    func collectionView(collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                                                          atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                               withReuseIdentifier: "profileTopBar",
                                                                               forIndexPath: indexPath) as! AchievementsCollectionReusableView
        let bucketlistImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(bucketlistPress(_:)))
        headerView.bucketlistImage.addGestureRecognizer(bucketlistImageTapGesture)
        headerView.achievementDescription.text = achievementDescription
        headerView.achievementCompleterCount.text = "\(achievementCompleterCount) har klarat detta"
        headerView.achievementScore.text = "\(achievementScore)p"
        headerView.tag = achievementId
        headerView.uploadButton.layer.cornerRadius = 5
        if achievementInBucketlist {
            headerView.bucketlistImage.image = removeFromBucketlistImage
        } else {
            headerView.bucketlistImage.image = addToBucketlistImage
        }
        if achievementCompleted {
            headerView.lockImage.image = unlockedIcon
            headerView.uploadButton.setTitle("Visa mitt inlägg", forState: .Normal)
        } else {
            headerView.uploadButton.setTitle(("Ladda upp"), forState: .Normal)
        }
        header = headerView
        return headerView
    }
    
    // MARK: User Interaction
    @IBAction func bucketlistPress(sender: AnyObject?) {
        if achievementCompleted {
            let ac = UIAlertController(title: "Avklarat uppdrag", message: "Du har redan klarat detta uppdrag och kan därför inte lägga till det i din lista", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            if header.bucketlistImage.image == addToBucketlistImage {
                achievementService.addToBucketlist(achievementId)
                header.bucketlistImage.image = removeFromBucketlistImage
            } else {
                achievementService.removeFromBucketlist(achievementId)
                header.bucketlistImage.image = addToBucketlistImage
            }
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
    
    @IBAction func showMore(sender: AnyObject?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Lägg till uppdrag i min lista", style: UIAlertActionStyle.Default, handler: { action in
            self.achievementService.addToBucketlist(self.achievementId)
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
    
    @IBAction func uploadPost(sender: AnyObject?) {
        if achievementCompleted {
            self.performSegueWithIdentifier("showPostFromAchievement", sender: achievementCompletedPostId)
        } else {
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
        
        if segue.identifier == "showProfileFromShowAchievement" {
            let vc = segue.destinationViewController as! ProfileViewController
            vc.userId = postUserIds[cellIndex]
        }
        
    }
    
    // MARK: Additional Helpers
    func fetchDataFromUrlToPostImages(fetchUrl: String) {
        let url = NSURL(string: self.url + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.postImages.append(image!)
    }
    
    func fetchDataFromUrlToPostUserAvatars(fetchUrl: String) {
        let url = NSURL(string: self.url + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.postUserAvatars.append(image!)
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
            let fixedImage = image?.fixOrientation()
            let imageData: NSData = UIImagePNGRepresentation(fixedImage!)!
            uploadService.uploadImage(imageData, achievementId: achievementId)
            newUpload = true
        } else if mediaType!.isEqualToString(kUTTypeMovie as String) {
            let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL)!
            newUpload = true
            uploadService.uploadVideo(pickedVideo, achievementId: achievementId)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func destroyCell(cellIndex: Int) {
        self.achievementCompleterCount -= 1
        self.achievementCompleted = false
        self.achievementCompletedPostId = 0
        self.postIds.removeAtIndex(cellIndex)
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
        playVideo(collectionView.centerCellIndexPath!.row)
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    func refreshView() {
        postIds = []
        postImageUrls = []
        postImages = []
        postVideoUrls = []
        postUserIds = []
        postUserNames = []
        postUserAvatarUrls = []
        postUserAvatars = []
        postCommentCounts = []
        postLikeCounts = []
        postLike = []
        morePostsToLoad = true
        segueShouldShowCompleters = false
        achievementService.getAchievement(achievementId)
        shouldRefresh = false
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
