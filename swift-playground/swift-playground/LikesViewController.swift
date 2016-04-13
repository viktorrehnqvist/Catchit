//
//  LikesViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 22/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class LikesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let postService = PostService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    var labels: [String] = []
    var images: [UIImage] = []
    var ids: [Int] = []
    var avatarUrls: [String] = []
    var avatars: [UIImage] = []
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAvatars()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatarUrls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("noticeCell", forIndexPath: indexPath) as! NoticeCollectionViewCell
        
        let noticeCellTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        cell.addGestureRecognizer(noticeCellTapGesture)
        cell.noticeLabel.text! = labels[indexPath.row]
        cell.noticeImage.image = avatars[indexPath.row]
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    @IBAction func showProfile(sender: AnyObject?) {
        self.performSegueWithIdentifier("showProfileFromLikes", sender: sender)
    }
    
    func loadAvatars() {
        if self.avatarUrls.count > 0 {
            print("avatars loaded")
            for avatarUrl in self.avatarUrls {
                print(avatarUrl)
                let url = NSURL(string: "http://localhost:3000" + avatarUrl)
                let data = NSData(contentsOfURL:url!)
                if data != nil {
                    avatars.append(UIImage(data: data!)!)
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
        }
    }
    
}