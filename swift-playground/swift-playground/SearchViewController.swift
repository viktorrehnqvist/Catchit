//
//  SearchViewController.swift
//  Catchit
//
//  Created by viktor johansson on 09/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import MobileCoreServices

class SearchViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, SearchServiceDelegate, UserServiceDelegate, UploadServiceDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Setup
    let postService = PostService()
    let searchService = SearchService()
    let userService = UserService()
    let uploadService = UploadService()
    let achievementService = AchievementService()
    @IBOutlet weak var searchField: UITextField!        
    @IBOutlet weak var collectionView: UICollectionView!
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    let defaultAvatar = UIImage(named: "avatar")
    let lockIcon = UIImage(named: "lock_icon")
    let unlockedIcon = UIImage(named: "unlocked_icon")
    let bucketlistAddIcon = UIImage(named: "bucketlist-add-icon")
    let bucketlistRemoveIcon = UIImage(named: "bucketlist-remove_icon")
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    var resultCount: Int = 0
    var searchObject: AnyObject = 0
    
    var userFollowIds: [Int] = []
    var completedAchievementIds: [Int] = []
    var completedPostIds: [Int] = []
    var bucketlistAchievementIds: [Int] = []
    var labels: [String] = []
    var ids: [Int] = []
    var types: [String] = []
    var imageUrls: [String] = []
    var images: [UIImage] = []
    var uploadAchievementId: Int?
    var uploadIndexPath: NSIndexPath?
    
    // MARK: Lifecycle
    func setSearchResult(json: AnyObject) {
        self.searchObject = json
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.labels = []
            self.ids = []
            self.types = []
            self.imageUrls = []
            self.images = []
            self.resultCount = json["search_results"]!!.count
            if json["search_results"]!!.count > 0 {
                for i in 0...(json["search_results"]!!.count - 1) {
                    self.labels.append(json["search_results"]!![i]["label"] as! String)
                    self.ids.append(json["search_results"]!![i]?["record_id"] as! Int)
                    self.types.append(json["search_results"]!![i]?["record_type"] as! String)
                    self.imageUrls.append(json["search_results"]!![i]?["record_image"] as! String)
                    self.fetchDataFromUrlToUserAvatars(json["search_results"]!![i]?["record_image"] as! String)
                }
            }
            if self.searchObject === json {
                NSOperationQueue.mainQueue().addOperationWithBlock(self.collectionView.reloadData)
            }
        })
    }
    
    func setUserData(json: AnyObject, follow: Bool) {
        userFollowIds = (json["follow_infos"] as! NSArray)[2] as! [Int]
        completedAchievementIds = (json["achievement_ids"] as! NSArray) as! [Int]
        completedPostIds = (json["post_ids"] as! NSArray) as! [Int]
        if json["bucketlist"]!!.count > 0 {
            for i in 0...(json["bucketlist"]!!.count - 1) {
                bucketlistAchievementIds.append((json["bucketlist"]!![i]["id"]) as! Int)
            }
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    func updateUserData(json: AnyObject) {
    }
    
    func setUploadedResult(json: AnyObject) {
        let postId = json["id"] as! Int
        completedAchievementIds.append(uploadAchievementId!)
        completedPostIds.append(postId)
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
        self.performSegueWithIdentifier("showPostFromSearch", sender: postId)
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        searchField.tintColor = UIColor.blueColor()
        super.viewDidLoad()
        collectionView.delegate = self
        searchService.delegate = self
        searchField.delegate = self
        searchField.becomeFirstResponder()
        userService.delegate = self
        userService.getCurrentUserData()
        uploadService.delegate = self
        if screenSize.width < 400 {
            searchField.layer.frame = CGRectMake(0 , 0, screenSize.width - 90, 30)
        } else {
            searchField.layer.frame = CGRectMake(0 , 0, screenSize.width - 100, 30)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        userFollowIds = []
        completedAchievementIds = []
        completedPostIds = []
        bucketlistAchievementIds = []
        userService.getCurrentUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SearchCollectionViewCell
        
        if types[indexPath.row] == "user" {
            if userFollowIds.contains(ids[indexPath.row]) {
                cell.resultButton.setTitle("Sluta följ", forState: .Normal)
            } else {
                cell.resultButton.setTitle("Följ", forState: .Normal)
            }
            cell.bucketlistButton.hidden = true
            cell.resultIcon.image = images[indexPath.row]
        } else {
            if completedAchievementIds.contains(ids[indexPath.row]) {
                cell.resultButton.setTitle("Visa inlägg", forState: .Normal)
                cell.resultIcon.image = unlockedIcon
                cell.bucketlistButton.hidden = true
            } else {
                cell.bucketlistButton.hidden = false
                if bucketlistAchievementIds.contains(ids[indexPath.row]) {
                    cell.bucketlistButton.setImage(bucketlistRemoveIcon, forState: .Normal)
                } else {
                    cell.bucketlistButton.setImage(bucketlistAddIcon, forState: .Normal)
                }
                cell.resultButton.setTitle("Ladda upp", forState: .Normal)
                cell.resultIcon.image = lockIcon
            }
        }
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.resultLabel.text! = labels[indexPath.row]
        cell.resultButton.layer.cornerRadius = 5
        cell.resultButton.tag = indexPath.row
        cell.bucketlistButton.tag = indexPath.row
            
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: screenSize.width, height: 46)
    }
    
    // MARK: User Interaction
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let recordId = ids[indexPath.row]
        if types[indexPath.row] == "achievement" {
            self.performSegueWithIdentifier("showAchievementFromSearch", sender: recordId)
        } else {
            self.performSegueWithIdentifier("showProfileFromSearch", sender: recordId)
        }
    }
    
    @IBAction func resultButtonPress(sender: AnyObject) {
        let index = sender.tag
        let indexPath = NSIndexPath(forItem: sender.tag, inSection: 0)
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SearchCollectionViewCell
        let recordId = ids[index]
        if types[index] == "achievement" {
            uploadAchievementId = recordId
            uploadIndexPath = indexPath
            if completedAchievementIds.contains(recordId) {
                let postId = completedPostIds[completedAchievementIds.indexOf(recordId)!]
                self.performSegueWithIdentifier("showPostFromSearch", sender: postId)
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
        } else {
            if cell.resultButton.titleForState(.Normal) == "Sluta följ" {
                userService.followUserChange(recordId, follow: false)
                cell.resultButton.setTitle("Följ", forState: .Normal)
            } else {
                userService.followUserChange(recordId, follow: true)
                cell.resultButton.setTitle("Sluta följ", forState: .Normal)
            }
        }
    }
    
    @IBAction func bucketlistPress(sender: AnyObject) {
        let indexPath = NSIndexPath(forItem: sender.tag, inSection: 0)
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SearchCollectionViewCell
        if cell.bucketlistButton.currentImage == bucketlistAddIcon {
            achievementService.addToBucketlist(ids[indexPath.row])
            cell.bucketlistButton.setImage(bucketlistRemoveIcon, forState: .Normal)
        } else {
            achievementService.removeFromBucketlist(ids[indexPath.row])
            cell.bucketlistButton.setImage(bucketlistAddIcon, forState: .Normal)
        }
    }

    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func resignKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }

    @IBAction func textDidChange(sender: AnyObject) {
        searchService.search(searchField.text!)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        if segue.identifier == "showAchievementFromSearch" {
            let vc = segue.destinationViewController as! ShowAchievementViewController
            vc.achievementId = sender?.integerValue
        }
        
        if segue.identifier == "showProfileFromSearch" {
            let vc = segue.destinationViewController as! ProfileViewController
            vc.userId = sender?.integerValue
        }
        
        if segue.identifier == "showPostFromSearch" {
            let vc = segue.destinationViewController as! ShowPostViewController
            vc.postId = sender?.integerValue!
        }
    }
    
    // MARK: Additional Helpers
    func fetchDataFromUrlToUserAvatars(fetchUrl: String) {
        let url = NSURL(string: self.url + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.images.append(image!)
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
            uploadService.uploadImage(imageData, achievementId: uploadAchievementId!)
        } else if mediaType!.isEqualToString(kUTTypeMovie as String) {
            let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL)!
            uploadService.uploadVideo(pickedVideo, achievementId: uploadAchievementId!)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
