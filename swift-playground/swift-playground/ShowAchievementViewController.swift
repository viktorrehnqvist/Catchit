//
//  ShowAchievementViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 28/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import MobileCoreServices

class ShowAchievementViewController: UIViewController, PostServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let postService = PostService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var collectionView: UICollectionView!
    var header: AchievementsCollectionReusableView!
    
    let addToBucketlistImage = UIImage(named: "achievement_button_icon3")
    let removeFromBucketlistImage = UIImage(named: "bucketlist-remove_icon")
    var achievementDescription: String!
    var achievementId: Int!
    var achievementScore: Int!
    var achievementCompleterCount: Int!
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
    
    
    func setPostData(json: AnyObject) {
        print(json)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postService.getPosts()
        self.postService.delegate = self
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
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        if segue.identifier == "showCommentsFromShowAchievement" {
            let vc = segue.destinationViewController as! NewViewController
            // Cant send tag from tap gesture, get comments from something else and delete next if
            print(vc)
            if (sender!.tag != nil) {
            }
        }
        if segue.identifier == "showLikesFromShowAchievement" {
        }
    }
    
}
