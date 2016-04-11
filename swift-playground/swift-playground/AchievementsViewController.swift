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
class AchievementsViewController: UIViewController, AchievementServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let achievementService = AchievementService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var collectionView: UICollectionView!
    
    let addToBucketlistImage = UIImage(named: "achievement_button_icon3")
    let removeFromBucketlistImage = UIImage(named: "bucketlist-remove_icon")
    var achievementDescriptions: [AnyObject]! = []
    var achievementIds: [Int] = []
    let imageArray = [UIImage(named: "4"), UIImage(named: "1"), UIImage(named: "3"), UIImage(named: "2"), UIImage(named: "4") ]
    
    func setAchievements(json: AnyObject) {
        print(json)
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                achievementDescriptions.append((json[i]?["description"])!)
                achievementIds.append((json[i]?["id"]) as! Int)
            }
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }

    func displayComments(comments: AnyObject) {
        print(comments)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        achievementService.getAchievements()
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
        
        cell.achievementLabel.text! = (achievementDescriptions?[indexPath.row])! as! String
        cell.bucketlistImage.image = addToBucketlistImage
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.uploadButton.layer.cornerRadius = 5
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let size = CGSize(width: screenSize.width, height: screenSize.width * 1.2)
            
            return size
    }
    
    @IBAction func showCompleters(sender: AnyObject?) {
        self.performSegueWithIdentifier("showLikesViewFromAchievement", sender: sender)
    }
    
    @IBAction func shareAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showLikesViewFromAchievement", sender: sender)
    }
    
    @IBAction func showAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAchievementFromAchievements", sender: sender)
    }
    
    @IBAction func bucketlistPress(sender: AnyObject?) {
        // Changes more than one achievement, fix this.
        let point = sender?.view
        let mainCell = point?.superview
        let main = mainCell?.superview
        let thisCell: AchievementCollectionViewCell = main as! AchievementCollectionViewCell
        if thisCell.bucketlistImage.image == addToBucketlistImage {
            thisCell.bucketlistImage.image = removeFromBucketlistImage
        } else {
            thisCell.bucketlistImage.image = addToBucketlistImage
        }
    }
    
    @IBAction func uploadPost(sender: AnyObject?) {
        // Make this a delegate.
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
    
    func loadMore(cellIndex: Int) {
        print(achievementIds.last!)
        if cellIndex == self.achievementDescriptions.count - 1 {
            achievementService.fetchMoreAchievements(achievementIds.last!)
        }
    }
    
}
