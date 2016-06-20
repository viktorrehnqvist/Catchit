//
//  BucketlistViewController.swift
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
class BucketlistViewController:  UIViewController, AchievementServiceDelegate, UploadServiceDelegate, UserServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    // MARK: Setup
    let achievementService = AchievementService()
    let uploadService = UploadService()
    let userService = UserService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchField: UITextField!
    var uploadAchievementId: Int?
    @IBOutlet weak var emptyImage: UIImageView!
    
    var achievementDescriptions: [String] = []
    var achievementIds: [Int] = []
    
    // MARK: Lifecycle
    func setAchievementData(json: AnyObject, firstFetch: Bool) {
        if json["bucketlist"]!!.count > 0 {
            for i in 0...(json["bucketlist"]!!.count - 1) {
                achievementDescriptions.append((json["bucketlist"]!![i]["description"])! as! String)
                achievementIds.append((json["bucketlist"]!![i]["id"]) as! Int)
            }
            emptyImage.hidden = true
        } else {
            emptyImage.hidden = false
        }
        collectionView.removeIndicators()
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    func updateAchievementsData(json: AnyObject) {
    }
    
    func setNewAchievementData(json: AnyObject) {
    }

    func setUploadedResult(json: AnyObject) {
        let postId = json["id"] as! Int
        self.performSegueWithIdentifier("showPostFromBucketlist", sender: postId)
    }
    
    func setUserData(json: AnyObject, follow: Bool) {}
    func updateUserData(json: AnyObject) {}
    func setNoticeData(notSeenNoticeCount: Int) {
        if notSeenNoticeCount > 0 {
            self.tabBarController?.tabBar.items?.last?.badgeValue = "\(Int(notSeenNoticeCount))"
        } else {
            self.tabBarController?.tabBar.items?.last?.badgeValue = nil
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.layer.frame = CGRectMake(0 , 0, screenSize.width - 80, 30)
        self.achievementService.delegate = self
        self.uploadService.delegate = self
        self.userService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionView.loadIndicatorMidWithHeader(screenSize)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.hidesBarsOnSwipe = false
        self.userService.getNotSeenNoticeCount()
        self.achievementDescriptions = []
        self.achievementIds = []
        self.achievementService.getBucketlist()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.achievementIds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("bucketlistCell", forIndexPath: indexPath) as! BucketlistCollectionViewCell
        
        let achievementTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievement(_:)))
        
        cell.achievementLabel.addGestureRecognizer(achievementTapGesture)
        cell.achievementLabel.text = achievementDescriptions[indexPath.row]
        cell.tag = indexPath.row
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.uploadButton.tag = achievementIds[indexPath.row]
        cell.uploadButton.layer.cornerRadius = 5
        cell.removeButton.addTarget(self, action: #selector(removeFromBucketlist(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let size = CGSize(width: screenSize.width, height: 50)
            
            return size
    }
    
    
    // MARK: User Interaction
    @IBAction func showAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAchievementFromBucketlist", sender: sender)
    }
    
    @IBAction func showSearch(sender: AnyObject) {
        self.performSegueWithIdentifier("showSearchFromBucketlist", sender: sender)
    }
    
    func removeFromBucketlist(sender: AnyObject) {
        let cell: BucketlistCollectionViewCell = sender.superview!!.superview! as! BucketlistCollectionViewCell
        let cellIndexPath = collectionView.indexPathForCell(cell)
        let cellIndex = cellIndexPath!.row
        let achievementId = achievementIds[cellIndex]
        achievementService.removeFromBucketlist(achievementId)
        achievementDescriptions.removeAtIndex(cellIndex)
        achievementIds.removeAtIndex(cellIndex)
        collectionView.deleteItemsAtIndexPaths([cellIndexPath!])
        if achievementIds.isEmpty {
            emptyImage.hidden = false
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
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
            let fixedImage = image?.fixOrientation()
            let imageData: NSData = UIImagePNGRepresentation(fixedImage!)!
            uploadService.uploadImage(imageData, achievementId: uploadAchievementId!)
        } else if mediaType!.isEqualToString(kUTTypeMovie as String) {
            let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL)!
            uploadService.uploadVideo(pickedVideo, achievementId: uploadAchievementId!)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let point = sender?.view
        let mainCell = point?.superview
        let main = mainCell?.superview
        if let thisCell: BucketlistCollectionViewCell = main as? BucketlistCollectionViewCell {
            let cellIndex = thisCell.tag
            if segue.identifier == "showAchievementFromBucketlist" {
                let vc = segue.destinationViewController as! ShowAchievementViewController
                vc.achievementId = achievementIds[cellIndex]
            }
        }
        
        if segue.identifier == "showPostFromBucketlist" {
            let vc = segue.destinationViewController as! ShowPostViewController
            vc.postId = sender!.integerValue
        }
        
    }
    
}