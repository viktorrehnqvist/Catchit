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
    let noPostImage = UIImage(named: "post")
    var achievementDescriptions: [String] = []
    var achievementIds: [Int] = []
    var achievementScores: [Int] = []
    var achievementCompleterCounts: [Int] = []
    var achievementFirstCompleterImages: [UIImage] = []
    var achievementSecondCompleterImages: [UIImage] = []
    var achievementThirdCompleterImages: [UIImage] = []
    var moreAchievementsToLoad: Bool = true

    func setAchievementData(json: AnyObject) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                achievementDescriptions.append((json[i]?["description"])! as! String)
                achievementIds.append((json[i]?["id"]) as! Int)
                achievementScores.append(json[i]?["score"] as! Int)
                achievementCompleterCounts.append(json[i]?["posts_count"] as! Int)
                //achievementCompleterUserId.append((json[i]?["completer_user_infos"]!![0] as? ([Int]))!)
                //achievementCompleterUserNames.append((json[i]?["completer_user_infos"]!![1] as? ([String]))!)
                //achievementCompleterUserAvatars.append((json[i]?["completer_user_infos"]!![2] as? ([String]))!)
                let postImagesToLoad = json[i]["latest_posts"]!!.count
                // Load first three postes for achievement
                for postIndex in 0...(postImagesToLoad - 1) {
                    if let completerImageUrl = json[i]["latest_posts"]?![postIndex] as? String {
                        let url = NSURL(string: "http://localhost:3000" + completerImageUrl)!
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
            achievementThirdCompleterImages.append(noPostImage!)
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
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
        
        cell.tag = achievementIds[indexPath.row]
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLikesViewFromAchievement" {
            let vc = segue.destinationViewController as! LikesViewController
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            let thisCell: AchievementCollectionViewCell = main as! AchievementCollectionViewCell
            vc.achievementId = thisCell.tag
            vc.typeIsPost = false
        }
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
        if cellIndex == self.achievementDescriptions.count - 1 && moreAchievementsToLoad {
            achievementService.fetchMoreAchievements(achievementIds.last!)
        }
    }
    
}
