//
//  AchievementsViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 19/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import MobileCoreServices

@available(iOS 9.0, *)
class AchievementsViewController: UIViewController, AchievementServiceDelegate, UploadServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Setup
    let achievementService = AchievementService()
    let uploadService = UploadService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    @IBOutlet weak var collectionView: UICollectionView!
    var uploadAchievementId: Int?
    
    let addToBucketlistImage = UIImage(named: "achievement_button_icon3")
    let removeFromBucketlistImage = UIImage(named: "bucketlist-remove_icon")
    let unlockedIcon = UIImage(named: "unlocked_icon")
    let lockedIcon = UIImage(named: "lock_icon")
    var noPostImage = UIImage(named: "post")
    var achievementCreatedAt: [String] = []
    var achievementUpdatedAt: [String] = []
    var achievementDescriptions: [String] = []
    var achievementIds: [Int] = []
    var achievementScores: [Int] = []
    var achievementCompleterCounts: [Int] = []
    var achievementFirstCompleterImages: [UIImage] = []
    var achievementSecondCompleterImages: [UIImage] = []
    var achievementThirdCompleterImages: [UIImage] = []
    var achievementInBucketlist: [Bool] = []
    var achievementCompleted: [Bool] = []
    var moreAchievementsToLoad: Bool = true
    var segueShouldShowCompleters: Bool = false
    
    // MARK: Lifecycle
    func setAchievementData(json: AnyObject, firstFetch: Bool) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                achievementCreatedAt.append((json[i]?["created_at"])! as! String)
                achievementUpdatedAt.append((json[i]?["updated_at"])! as! String)
                achievementDescriptions.append((json[i]?["description"])! as! String)
                achievementIds.append((json[i]?["id"]) as! Int)
                achievementScores.append(json[i]?["score"] as! Int)
                achievementCompleterCounts.append(json[i]?["posts_count"] as! Int)
                achievementInBucketlist.append(json[i]?["bucketlist"] as! Bool)
                achievementCompleted.append(json[i]?["completed"] as! Bool)
                let postImagesToLoad = json[i]["latest_posts"]!!.count
                // Load first three postes for achievement
                if postImagesToLoad > 0 {
                    for postIndex in 0...(postImagesToLoad - 1) {
                        if let completerImageUrl = (json[i]["latest_posts"] as! NSArray)[postIndex] as? String {
                            let url = NSURL(string: self.url + completerImageUrl)!
                            let data = NSData(contentsOfURL:url)
                            if data != nil {
                                switch postIndex {
                                case 0:
                                    achievementFirstCompleterImages.append(UIImage(data: data!)!)
                                case 1:
                                    achievementSecondCompleterImages.append(UIImage(data: data!)!)
                                case 2:
                                    achievementThirdCompleterImages.append(UIImage(data: data!)!)
                                default:
                                    print("Switch Error")
                                }
                            }
                        }
                    }
                }
                var postsAlreadyLoaded = postImagesToLoad
                while postsAlreadyLoaded < 3 {
                    switch postsAlreadyLoaded {
                    case 0:
                        achievementFirstCompleterImages.append(noPostImage!)
                    case 1:
                        achievementSecondCompleterImages.append(noPostImage!)
                    case 2:
                        achievementThirdCompleterImages.append(noPostImage!)
                    default:
                        print("Switch Error")
                    }
                    postsAlreadyLoaded! += 1
                }
            }
        } else {
            moreAchievementsToLoad = false
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    func updateAchievementsData(json: AnyObject) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                let achievementId = json[i]?["id"] as! Int
                if let cellIndex = achievementIds.indexOf({$0 == achievementId}) {
                    achievementScores[cellIndex] = json[i]?["score"] as! Int
                    achievementUpdatedAt[cellIndex] = json[i]?["updated_at"] as! String
                    achievementCompleterCounts[cellIndex] = json[i]?["posts_count"] as! Int
                    achievementInBucketlist[cellIndex] = json[i]?["bucketlist"] as! Bool
                    achievementCompleted[cellIndex] = json[i]?["completed"] as! Bool
                    let postImagesToLoad = json[i]["latest_posts"]!!.count
                    if postImagesToLoad > 0 {
                        for postIndex in 0...(postImagesToLoad - 1) {
                            if let completerImageUrl = (json[i]["latest_posts"] as! NSArray)[postIndex] as? String {
                                let url = NSURL(string: self.url + completerImageUrl)!
                                let data = NSData(contentsOfURL:url)
                                if data != nil {
                                    switch postIndex {
                                    case 0:
                                        achievementFirstCompleterImages[cellIndex] = UIImage(data: data!)!
                                    case 1:
                                        achievementSecondCompleterImages[cellIndex] = UIImage(data: data!)!
                                    case 2:
                                        achievementThirdCompleterImages[cellIndex] = UIImage(data: data!)!
                                    default:
                                        print("Switch Error")
                                    }
                                }
                            }
                        }
                    }
                    var postsAlreadyLoaded = postImagesToLoad
                    while postsAlreadyLoaded < 3 {
                        switch postsAlreadyLoaded {
                        case 0:
                            achievementFirstCompleterImages[cellIndex] = noPostImage!
                        case 1:
                            achievementSecondCompleterImages[cellIndex] = noPostImage!
                        case 2:
                            achievementThirdCompleterImages[cellIndex] = noPostImage!
                        default:
                            print("Switch Error")
                        }
                        postsAlreadyLoaded! += 1
                    }

                }
                
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
        }
    }
    
    func setNewAchievementData(json: AnyObject) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                achievementCreatedAt.insert(((json[i]?["created_at"])! as! String), atIndex: 0)
                achievementUpdatedAt.insert(((json[i]?["updated_at"])! as! String), atIndex: 0)
                achievementDescriptions.insert(((json[i]?["description"])! as! String), atIndex: 0)
                achievementIds.insert(((json[i]?["id"]) as! Int), atIndex: 0)
                achievementScores.insert((json[i]?["score"] as! Int), atIndex: 0)
                achievementCompleterCounts.insert((json[i]?["posts_count"] as! Int), atIndex: 0)
                achievementInBucketlist.insert((json[i]?["bucketlist"] as! Bool), atIndex: 0)
                achievementCompleted.insert((json[i]?["completed"] as! Bool), atIndex: 0)
                let postImagesToLoad = json[i]["latest_posts"]!!.count
                // Load first three postes for achievement
                if postImagesToLoad > 0 {
                    for postIndex in 0...(postImagesToLoad - 1) {
                        if let completerImageUrl = (json[i]["latest_posts"] as! NSArray)[postIndex] as? String {
                            let url = NSURL(string: self.url + completerImageUrl)!
                            let data = NSData(contentsOfURL:url)
                            if data != nil {
                                switch postIndex {
                                case 0:
                                    achievementFirstCompleterImages.insert((UIImage(data: data!)!), atIndex: 0)
                                case 1:
                                    achievementSecondCompleterImages.insert((UIImage(data: data!)!), atIndex: 0)
                                case 2:
                                    achievementThirdCompleterImages.insert((UIImage(data: data!)!), atIndex: 0)
                                default:
                                    print("Switch Error")
                                }
                            }
                        }
                    }
                }
                var postsAlreadyLoaded = postImagesToLoad
                while postsAlreadyLoaded < 3 {
                    switch postsAlreadyLoaded {
                    case 0:
                        achievementFirstCompleterImages.insert((noPostImage!), atIndex: 0)
                    case 1:
                        achievementSecondCompleterImages.insert((noPostImage!), atIndex: 0)
                    case 2:
                        achievementThirdCompleterImages.insert((noPostImage!), atIndex: 0)
                    default:
                        print("Switch Error")
                    }
                    postsAlreadyLoaded! += 1
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
            collectionView.setContentOffset(CGPointMake(0, -collectionView.contentInset.top), animated:true)
        }
    }
    
    func setUploadedResult(json: AnyObject) {
        let postId = json["id"] as! Int
        self.performSegueWithIdentifier("showPostFromAchievements", sender: postId)
    }
    
    func loadMore(cellIndex: Int) {
        if cellIndex == self.achievementDescriptions.count - 1 && moreAchievementsToLoad {
            achievementService.fetchMoreAchievements(achievementIds.last!)
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        achievementService.getAchievements()
        self.achievementService.delegate = self
        self.uploadService.delegate = self
        self.collectionView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        achievementService.updateAchievements(achievementIds, updatedAt: achievementUpdatedAt)
        if achievementIds.first != nil {
            achievementService.getNewAchievements(achievementIds.first!)
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.achievementDescriptions.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        loadMore(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("achievementCell", forIndexPath: indexPath) as! AchievementCollectionViewCell
        
        let completersTapGesture = UITapGestureRecognizer(target: self, action: #selector(showCompleters(_:)))
        let shareTapGesture = UITapGestureRecognizer(target: self, action: #selector(shareAchievement(_:)))
        let bucketlistTapGesture = UITapGestureRecognizer(target: self, action: #selector(bucketlistPress(_:)))
        let achievementTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievement(_:)))
        
        cell.tag = indexPath.row
        cell.completersImage.addGestureRecognizer(completersTapGesture)
        cell.shareImage.addGestureRecognizer(shareTapGesture)
        cell.bucketlistImage.addGestureRecognizer(bucketlistTapGesture)
        cell.achievementLabel.addGestureRecognizer(achievementTapGesture)
        
        cell.achievementImage1.image = achievementFirstCompleterImages[indexPath.row]
        cell.achievementImage2.image = achievementSecondCompleterImages[indexPath.row]
        cell.achievementImage3.image = achievementThirdCompleterImages[indexPath.row]
        cell.completersLabel.text! = String(achievementCompleterCounts[indexPath.row]) + " har klarat detta"
        cell.achievementLabel.text! = achievementDescriptions[indexPath.row]
        cell.scoreLabel.text! = String(achievementScores[indexPath.row])
        if achievementInBucketlist[indexPath.row] {
            cell.bucketlistImage.image = removeFromBucketlistImage
        } else {
            cell.bucketlistImage.image = addToBucketlistImage
        }
        if achievementCompleted[indexPath.row] {
            cell.lockImage.image = unlockedIcon
            cell.bucketlistImage.gestureRecognizers?.removeAll()
        } else {
            cell.lockImage.image = lockedIcon
        }
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.uploadButton.layer.cornerRadius = 5
        cell.uploadButton.tag = achievementIds[indexPath.row]
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let size = CGSize(width: screenSize.width, height: screenSize.width * 1.2)
            
            return size
    }
    
    // MARK: User Interaction
    @IBAction func showCompleters(sender: AnyObject?) {
        self.segueShouldShowCompleters = true
        self.performSegueWithIdentifier("showLikesViewFromAchievement", sender: sender)
    }
    
    @IBAction func shareAchievement(sender: AnyObject?) {
        self.segueShouldShowCompleters = false
        self.performSegueWithIdentifier("showLikesViewFromAchievement", sender: sender)
    }
    
    @IBAction func showAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAchievementFromAchievements", sender: sender)
    }
    
    @IBAction func showSearch(sender: AnyObject) {
        self.performSegueWithIdentifier("showSearchFromAchievements", sender: sender)
    }
    
    @IBAction func bucketlistPress(sender: AnyObject?) {
        let point = sender?.view
        let mainCell = point?.superview
        let main = mainCell?.superview
        let thisCell: AchievementCollectionViewCell = main as! AchievementCollectionViewCell
        let cellIndex = thisCell.tag
        if thisCell.bucketlistImage.image == addToBucketlistImage {
            achievementService.addToBucketlist(achievementIds[cellIndex])
            thisCell.bucketlistImage.image = removeFromBucketlistImage
        } else {
            achievementService.removeFromBucketlist(achievementIds[cellIndex])
            thisCell.bucketlistImage.image = addToBucketlistImage
        }
    }
    
    @IBAction func uploadPost(sender: AnyObject?) {
        uploadAchievementId = sender!.tag
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
            uploadService.uploadImage(imageData, achievementId: uploadAchievementId!)
        } else if mediaType!.isEqualToString(kUTTypeMovie as String) {
            let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL)!
            uploadService.uploadVideo(pickedVideo, achievementId: uploadAchievementId!)
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var cellIndex: Int = 0
        if sender?.integerValue != nil {
            // Uploaded post, send to specific post, this should be changed for better readability.
            let vc = segue.destinationViewController as! ShowPostViewController
            vc.postId = sender?.integerValue
        } else {
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            if let thisCell: AchievementCollectionViewCell = main as? AchievementCollectionViewCell {
                cellIndex = thisCell.tag
            }
            if segue.identifier == "showLikesViewFromAchievement" {
                let vc = segue.destinationViewController as! LikesViewController
                vc.achievementId = achievementIds[cellIndex]
                if segueShouldShowCompleters {
                    vc.typeIs = "achievementCompleters"
                } else {
                    vc.typeIs = "achievementShare"
                }
            }
            
            if segue.identifier == "showAchievementFromAchievements" {
                let vc = segue.destinationViewController as! ShowAchievementViewController
                vc.achievementId = achievementIds[cellIndex]
            }
        }
    }
    
    
}
