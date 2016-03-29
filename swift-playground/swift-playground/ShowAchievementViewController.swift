//
//  ShowAchievementViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 28/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class ShowAchievementViewController: UIViewController, PostServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let postService = PostService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    
    func setPosts(json: AnyObject) {
        print(json)
    }
    
    func displayComments(comments: AnyObject) {
        print(comments)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let appleProducts = ["Bestig ett berg", "Posera jämte en polis", "Klappa en igelkott", "Spring ett maraton", "Spring ett maraton"]
    
    let imageArray = [UIImage(named: "1"), UIImage(named: "2"), UIImage(named: "4"), UIImage(named: "3"), UIImage(named: "3") ]
    
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
        cell.imageView?.image = self.imageArray[indexPath.row]
        cell.label?.text = self.appleProducts[indexPath.row]
        cell.commentButton?.tag = indexPath.row
        cell.commentCount?.tag = indexPath.row
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let image = self.imageArray[indexPath.row]!
        let heightFactor = image.size.height / image.size.width
        let size = CGSize(width: screenSize.width, height: heightFactor * screenSize.width + 160)
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                                                          atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                               withReuseIdentifier: "profileTopBar",
                                                                               forIndexPath: indexPath)
        return headerView
    }
    
    
    @IBAction func bucketlistPress(sender: AnyObject?) {
        // Change bucketlist-image.
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        if segue.identifier == "showCommentsFromShowAchievement" {
            let vc = segue.destinationViewController as! NewViewController
            // Cant send tag from tap gesture, get comments from something else and delete next if
            if (sender!.tag != nil) {
                vc.comments = self.commentsArray[sender!.tag]
            }
        }
        if segue.identifier == "showLikesFromShowAchievement" {
        }
    }
    
}
