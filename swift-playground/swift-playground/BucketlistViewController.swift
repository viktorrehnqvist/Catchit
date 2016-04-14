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
class BucketlistViewController:  UIViewController, PostServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    let postService = PostService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    
    func setPostData(json: AnyObject) {
        print(json)
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
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
        return 30
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("bucketlistCell", forIndexPath: indexPath) as! BucketlistCollectionViewCell
        
        let achievementTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievement(_:)))
        
        cell.achievementLabel.addGestureRecognizer(achievementTapGesture)
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.uploadButton.layer.cornerRadius = 5
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
    
    @IBAction func showAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAchievementFromBucketlist", sender: sender)
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
    
    
}