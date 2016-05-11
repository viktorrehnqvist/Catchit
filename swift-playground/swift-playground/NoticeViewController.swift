//
//  NoticeViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 19/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

@available(iOS 9.0, *)
class NoticeViewController:  UIViewController, UserServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Setup
    let userService = UserService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var collectionView: UICollectionView!
    
    var noticeMessages: [String] = []
    var noticeUserIds: [Int] = []
    var noticeUserAvatarUrls: [String] = []
    var noticeUserAvatars: [UIImage] = []
    var noticeTypes: [String] = []
    var noticeLinkIds: [Int] = []
    var noticeSeen: [AnyObject] = []
    
    // MARK: Lifecycle
    func setUserData(json: AnyObject, follow: Bool) {
        noticeUserIds = (json["notice_infos"] as! NSArray)[0] as! [Int]
        noticeUserAvatarUrls = (json["notice_infos"] as! NSArray)[1] as! [String]
        noticeMessages = (json["notice_infos"] as! NSArray)[2] as! [String]
        noticeTypes = (json["notice_infos"] as! NSArray)[3] as! [String]
        noticeLinkIds = (json["notice_infos"] as! NSArray)[4] as! [Int]
        noticeSeen = (json["notice_infos"] as! NSArray)[5] as! [AnyObject]
        loadAvatars()
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.noticeMessages = []
        self.noticeUserIds = []
        self.noticeUserAvatarUrls = []
        self.noticeUserAvatars = []
        self.noticeTypes = []
        self.noticeLinkIds = []
        self.noticeSeen = []
        userService.getCurrentUserData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.noticeMessages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("noticeCell", forIndexPath: indexPath) as! NoticeCollectionViewCell
        
        let noticeTapGesture = UITapGestureRecognizer(target: self, action: #selector(showNoticeOrigin(_:)))
        let avatarTapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        
        cell.tag = indexPath.row
        cell.noticeLabel.addGestureRecognizer(noticeTapGesture)
        cell.noticeImage.addGestureRecognizer(avatarTapGesture)
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.noticeImage.image = noticeUserAvatars[indexPath.row]
        cell.noticeLabel.text! = noticeMessages[indexPath.row]
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let size = CGSize(width: screenSize.width, height: 50)
            
            return size
    }
    
    // MARK: User Interaction
    @IBAction func showNoticeOrigin(sender: AnyObject?) {
        // Check if sender is of type achievement or like and send to correct origin.
        let point = sender?.view
        let mainCell = point?.superview
        let main = mainCell?.superview
        let thisCell: NoticeCollectionViewCell = main as! NoticeCollectionViewCell
        let cellIndex = thisCell.tag
        if noticeTypes[cellIndex] == "tip" {
            self.performSegueWithIdentifier("showAchievementFromNotice", sender: thisCell)
        } else {
            self.performSegueWithIdentifier("showPostFromNotice", sender: thisCell)
        }
    }
    
    @IBAction func showProfile(sender: AnyObject?) {
        self.performSegueWithIdentifier("showProfileFromNotice", sender: sender)
    }
    
    @IBAction func showSearch(sender: AnyObject) {
        self.performSegueWithIdentifier("showSearchFromNotice", sender: sender)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       let cellIndex = sender!.tag
        
        if segue.identifier == "showAchievementFromNotice" {
            let vc = segue.destinationViewController as! ShowAchievementViewController
            vc.achievementId = noticeLinkIds[cellIndex]
        }
        
        if segue.identifier == "showPostFromNotice" {
            let vc = segue.destinationViewController as! ShowPostViewController
            vc.postId = noticeLinkIds[cellIndex]
        }
        
        if segue.identifier == "showProfileFromNotice" {
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            let thisCell: NoticeCollectionViewCell = main as! NoticeCollectionViewCell
            let cellIndex = thisCell.tag
            let vc = segue.destinationViewController as! ProfileViewController
            vc.userId = noticeUserIds[cellIndex]
        }
        
    }
    
    // MARK: Additional Helpers
    func loadAvatars() {
        if self.noticeUserAvatarUrls.count > 0 {
            for avatarUrl in self.noticeUserAvatarUrls {
                let url = NSURL(string: "http://192.168.1.116:3000" + avatarUrl)
                let data = NSData(contentsOfURL:url!)
                if data != nil {
                    noticeUserAvatars.append(UIImage(data: data!)!)
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
        }
    }
    
}