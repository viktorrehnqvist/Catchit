//
//  ShowPostViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 11/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

extension UILabel{
    
    func requiredHeight() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        return label.frame.height
    }
}

class ShowPostViewController: UIViewController, UICollectionViewDelegate, PostServiceDelegate, UserServiceDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    // MARK: Setup
    var header: ShowPostCollectionReusableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    let postService = PostService()
    let userService = UserService()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var currentUsername: String?
    var currentUserAvatar: UIImage?
    var currentUserId: Int?
    var achievementId: Int!
    var userId: Int!
    var postImage: UIImage!
    var postImageUrl: String!
    var likesCount: Int!
    var commentsCount: Int!
    var userName: String!
    var userAvatar: UIImage!
    var userAvatarUrl: String!
    var achievementScore: Int!
    var achievementDescription: String!
    var postId: Int!
    var postHeight: Int!
    var comments: [String] = []
    var commentUserAvatarUrls: [String] = []
    var commentUserAvatars: [UIImage] = []
    var commentUserNames: [String] = []
    var commentUserIds: [Int] = []
    var postIsVideo: Bool = false
    var postVideoUrl: String?
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    
    // MARK: Lifecycle
    func setPostData(json: AnyObject) {
        postImageUrl = json["image_url"] as! String
        userId = json["user_id"] as! Int
        achievementId = json["achievement_id"] as! Int
        userName = json["user_name"] as! String
        userAvatarUrl = json["user_avatar_url"] as! String
        likesCount = json["likes_count"] as! Int
        commentsCount = json["comments_count"] as! Int
        if ((json["video"]!!["video"]!!["url"] as? String) != nil) {
            postIsVideo = true
            postVideoUrl = json["video"]!!["video"]!!["url"] as? String
        }
        achievementDescription = json["achievement_description"] as! String
        achievementScore = json["achievement_score"] as! Int
        commentUserNames = (json["commenter_infos"] as! NSArray)[0] as! [String]
        commentUserAvatarUrls = (json["commenter_infos"] as! NSArray)[1] as! [String]
        commentUserIds = (json["commenter_infos"] as! NSArray)[2] as! [Int]
        comments = (json["commenter_infos"] as! NSArray)[3] as! [String]
        loadImageFromUrls()
    }
    
    func updatePostData(json: AnyObject) {
    }
    
    func setNewPostData(json: AnyObject) {
        
    }
    
    func setUserData(json: AnyObject, follow: Bool) {
        fetchDataFromUrlToCurrentUserAvatar((json["avatar_url"] as? String)!)
    }
    
    func updateUserData(json: AnyObject) {
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUserId = userDefaults.objectForKey("id") as? Int
        self.userService.delegate = self
        self.userService.getCurrentUserData()
        self.postService.getPost(postId!)
        self.postService.delegate = self
        self.currentUsername = userDefaults.objectForKey("name") as? String
        textField.delegate = self
        borderBottom(self.view)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    
    // MARK: Layout
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("commentCell", forIndexPath: indexPath) as! ShowPostCollectionViewCell
        
        let profileLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        cell.profileLabel.addGestureRecognizer(profileLabelTapGesture)
        cell.profileImage.addGestureRecognizer(profileImageTapGesture)
        cell.label?.text = self.comments[indexPath.row]
        cell.profileLabel.text = self.commentUserNames[indexPath.row]
        cell.profileImage.image = self.commentUserAvatars[indexPath.row]
        cell.label.numberOfLines = 0
        cell.tag = indexPath.row
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: 0, width:  cell.frame.size.width, height: 1)
        border.borderWidth = width
        cell.layer.addSublayer(border)
        cell.layer.masksToBounds = true
        cell.label.sizeToFit()
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let label = UILabel(frame: CGRectMake(0, 0, 120, 0))
            label.text = self.comments[indexPath.row]
            label.font = label.font.fontWithSize(12)
            label.numberOfLines = 0
            // Calculates the required height for this comment depending on content.
            // Requires fix.
            var newLabelHeight = label.requiredHeight()
            if newLabelHeight < 45 {
                newLabelHeight = 50
            } else if newLabelHeight < 75 {
                newLabelHeight = 65
        }
            let size = CGSize(width: screenSize.width, height: newLabelHeight * 0.8)
        
            return size
    }
    
    func collectionView(collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                                                          atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                               withReuseIdentifier: "commentsTopBar",
                                                                               forIndexPath: indexPath) as! ShowPostCollectionReusableView
        let achievementTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievement(_:)))
        let likesTapGesture = UITapGestureRecognizer(target: self, action: #selector(showLikes(_:)))
        let profileLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        headerView.achievementLabel.addGestureRecognizer(achievementTapGesture)
        headerView.likesCount.addGestureRecognizer(likesTapGesture)
        headerView.profileLabel.addGestureRecognizer(profileLabelTapGesture)
        headerView.profileImage.addGestureRecognizer(profileImageTapGesture)
        headerView.achievementLabel.text = achievementDescription
        headerView.commentsCount.text = String(commentsCount)
        headerView.likesCount.text = String(likesCount)
        headerView.profileLabel.text = userName
        headerView.profileImage.image = userAvatar
        headerView.scoreLabel.text = "\(achievementScore)p"
        
        if postIsVideo {
            let player = AVPlayer(URL: NSURL(string: url + self.postVideoUrl!)!)
            let playerController = AVPlayerViewController()
            
            playerController.player = player
            self.addChildViewController(playerController)
            collectionView.addSubview(playerController.view)
            
            let image = postImage
            var height = image.size.height
            if image.size.width > screenSize.width {
                let resizeFactor = screenSize.width / image.size.width
                height = resizeFactor * image.size.height
            }
            playerController.view.frame = CGRect(x: 0, y: 50, width: screenSize.width, height: height * 0.5)
        } else {
            headerView.postImage.image = postImage
        }
        header = headerView
        return headerView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var size: CGSize = CGSize(width: 0, height: 0)
        let image = self.postImage
        if image != nil {
            var height = image.size.height
            if image.size.width > screenSize.width {
                let resizeFactor = screenSize.width / image.size.width
                height = resizeFactor * image.size.height
            }
            if postIsVideo {
                size = CGSize(width: screenSize.width, height: height * 0.5 + 110)
            } else {
                size = CGSize(width: screenSize.width, height: height + 110)
            }
        }
        return size
    }
    
    func borderBottom(view: AnyObject) {
        let border = CALayer()
        let width = CGFloat(5)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: view.frame.size.height - 100, width:  view.frame.size.width, height: view.frame.size.height)
        border.borderWidth = width
        // This should be fixed to add border to the frame end of scroll view before using it.
        //view.layer.addSublayer(border)
    }

    // MARK: User Interaction
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        createComment()
        return true
    }
    
    @IBAction func showAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAchievementFromComments", sender: sender)
    }
    
    @IBAction func showLikes(sender: AnyObject?) {
        self.performSegueWithIdentifier("showLikesFromComments", sender: sender)
    }
    
    @IBAction func showProfile(sender: AnyObject?) {
        self.performSegueWithIdentifier("showProfileFromComments", sender: sender)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        var cellIndex: Int?
        let point = sender?.view
        let mainCell = point?.superview
        let main = mainCell?.superview
        if let thisCell: ShowPostCollectionViewCell = main as? ShowPostCollectionViewCell {
            cellIndex = thisCell.tag
            if segue.identifier == "showProfileFromComments" {
                let vc = segue.destinationViewController as! ProfileViewController
                vc.userId = commentUserIds[cellIndex!]
            }
        } else {
            if segue.identifier == "showProfileFromComments" {
                let vc = segue.destinationViewController as! ProfileViewController
                vc.userId = userId
            }
        }
        
        if segue.identifier == "showLikesFromComments" {
            let vc = segue.destinationViewController as! LikesViewController
            vc.typeIs = "post"
            vc.postId = postId
        }
        
        if segue.identifier == "showAchievementFromComments" {
            let vc = segue.destinationViewController as! ShowAchievementViewController
            vc.achievementId = achievementId
        }

    }
    
    // MARK: Additional Helpers
    func loadImageFromUrls() {
        if self.commentUserAvatarUrls.count > 0 {
            for avatarUrl in self.commentUserAvatarUrls {
                let url = NSURL(string: self.url + avatarUrl)
                let data = NSData(contentsOfURL:url!)
                if data != nil {
                    commentUserAvatars.append(UIImage(data: data!)!)
                }
            }
            
        }
        var url = NSURL(string: self.url + postImageUrl)
        var data = NSData(contentsOfURL: url!)
        postImage = UIImage(data: data!)
        url = NSURL(string: self.url + userAvatarUrl)
        data = NSData(contentsOfURL: url!)
        userAvatar = UIImage(data: data!)

        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    func fetchDataFromUrlToCurrentUserAvatar(fetchUrl: String) {
        let url = NSURL(string: self.url + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.currentUserAvatar = image!
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat, moveSpeed:Double){
        // Lifts the view
        let movementDuration:NSTimeInterval = moveSpeed
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    func createComment () {
        guard !textField.text!.isEmpty else {
            return
        }
        header.commentsCount.text = String(Int(header.commentsCount.text!)! + 1)
        postService.createComment(textField.text!, postId: postId)
        let indexPath = NSIndexPath(forItem: self.comments.count, inSection: 0)
        comments.insert(textField.text!, atIndex: self.comments.count)
        commentUserNames.insert(currentUsername!, atIndex: self.commentUserNames.count)
        commentUserAvatars.insert(currentUserAvatar!, atIndex: self.commentUserAvatars.count)
        commentUserIds.insert(currentUserId!, atIndex: self.commentUserIds.count)
        collectionView.insertItemsAtIndexPaths([indexPath])
        textField.text = ""
        collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
    }

}
