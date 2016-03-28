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

@available(iOS 9.0, *)
class AchievementsViewController: UIViewController, PostServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let postService = PostService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    
    func setPosts(json: AnyObject) {
        print(json)
    }
    
    func displayComments(comments: AnyObject) {
        print(comments)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let appleProducts = ["Utforska en skog", "Spill vatten på en hammare", "Cykla", "Spela en tennismatch", "Kör gokart"]
    
    let imageArray = [UIImage(named: "4"), UIImage(named: "1"), UIImage(named: "3"), UIImage(named: "2"), UIImage(named: "4") ]
    
    let commentsArray = [["Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt", "2", "Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt.", "Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt", "Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt", "2", "Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt.", "Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt"], ["test"], [], ["1"], [], ["1", "2", "3"], ["1", "2", "3", "4", "5", "6"]]
    
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
        return self.appleProducts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("achievementCell", forIndexPath: indexPath) as! AchievementCollectionViewCell
        
        let completersTapGesture = UITapGestureRecognizer(target: self, action: #selector(AchievementsViewController.showCompleters(_:)))
        let shareTapGesture = UITapGestureRecognizer(target: self, action: #selector(AchievementsViewController.shareAchievement(_:)))
        let bucketlistTapGesture = UITapGestureRecognizer(target: self, action: #selector(AchievementsViewController.bucketlistPress(_:)))
        
        cell.tag = indexPath.row
        cell.completersImage.addGestureRecognizer(completersTapGesture)
        cell.shareImage.addGestureRecognizer(shareTapGesture)
        cell.bucketlistImage.addGestureRecognizer(bucketlistTapGesture)
        
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
    
    @IBAction func bucketlistPress(sender: AnyObject?) {
        let point = sender?.view
        let mainCell = point?.superview
        let main = mainCell?.superview
        let cell: AchievementCollectionViewCell = main as! AchievementCollectionViewCell
        if cell.bucketlistImage.image == UIImage(named: "achievement_button_icon3") {
            cell.bucketlistImage.image = UIImage(named: "bucketlist-remove_icon")
        } else {
            cell.bucketlistImage.image = UIImage(named: "achievement_button_icon3")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCommentsFromHome" {
            let vc = segue.destinationViewController as! NewViewController
            // Cant send tag from tap gesture, get comments from something else and delete next if
            if (sender!.tag != nil) {
                vc.comments = self.commentsArray[sender!.tag]
            }
        }
        if segue.identifier == "showLikesFromHome" {
        }
    }

    
    
    
}
