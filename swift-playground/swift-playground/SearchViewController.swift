//
//  SearchViewController.swift
//  Catchit
//
//  Created by viktor johansson on 09/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, SearchServiceDelegate, UserServiceDelegate {
    
    // MARK: Setup
    let postService = PostService()
    let searchService = SearchService()
    let userService = UserService()
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
    
    var userFollowIds: [Int] = []
    var completedAchievementIds: [Int] = []
    var bucketlistAchievementIds: [Int] = []
    var labels: [String] = []
    var ids: [Int] = []
    var types: [String] = []
    var imageUrls: [String] = []
    var images: [UIImage] = []
    
    // MARK: Lifecycle
    func setSearchResult(json: AnyObject) {
        labels = []
        ids = []
        types = []
        imageUrls = []
        images = []
        resultCount = json.count
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                labels.append(json[i]["label"] as! String)
                ids.append(json[i]?["record_id"] as! Int)
                types.append(json[i]?["record_type"] as! String)
                imageUrls.append(json[i]?["record_image"] as! String)
                fetchDataFromUrlToUserAvatars(json[i]?["record_image"] as! String)
            }
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    func setUserData(json: AnyObject, follow: Bool) {
        userFollowIds = (json["follow_infos"] as! NSArray)[2] as! [Int]
        if (json["posts"] as! NSArray).count > 0 {
            for i in 0...((json["posts"] as! NSArray).count - 1) {
                completedAchievementIds.append((json["posts"] as! NSArray)[i]["achievement_id"] as! Int)
            }
        }
        if json["bucketlist"]!!.count > 0 {
            for i in 0...(json["bucketlist"]!!.count - 1) {
                bucketlistAchievementIds.append((json["bucketlist"]!![i]["id"]) as! Int)
            }
        }
    }
    
    func updateUserData(json: AnyObject) {
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        searchService.delegate = self
        searchField.delegate = self
        searchField.becomeFirstResponder()
        userService.delegate = self
        userService.getCurrentUserData()
        if screenSize.width < 400 {
            searchField.layer.frame = CGRectMake(0 , 0, screenSize.width - 90, 30)
        } else {
            searchField.layer.frame = CGRectMake(0 , 0, screenSize.width - 100, 30)
        }
        // Do any additional setup after loading the view.
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
    }
    
    // MARK: Additional Helpers
    func fetchDataFromUrlToUserAvatars(fetchUrl: String) {
        let url = NSURL(string: self.url + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.images.append(image!)
    }

}
