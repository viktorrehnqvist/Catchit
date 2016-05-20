//
//  SearchViewController.swift
//  Catchit
//
//  Created by viktor johansson on 09/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, SearchServiceDelegate {
    
    // MARK: Setup
    let postService = PostService()
    let searchService = SearchService()
    @IBOutlet weak var searchField: UITextField!        
    @IBOutlet weak var collectionView: UICollectionView!
    let defaultAvatar = UIImage(named: "avatar")
    let lockIcon = UIImage(named: "lock_icon")
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    var resultCount: Int = 0
    
    var labels: [String] = []
    var ids: [Int] = []
    var types: [String] = []
    
    // MARK: Lifecycle
    func setSearchResult(json: AnyObject) {
        labels = []
        ids = []
        types = []
        resultCount = json.count
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                labels.append(json[i]["label"] as! String)
                ids.append(Int(json[i]?["id"] as! String)!)
                if i == 1 {
                    types.append("user")
                } else {
                    types.append("achievement")
                }
            }
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        searchService.delegate = self
        searchField.delegate = self
        searchField.becomeFirstResponder()
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
            cell.resultButton.setTitle("Följ", forState: .Normal)
            cell.bucketlistButton.hidden = true
            cell.resultIcon.image = defaultAvatar
        } else {
            cell.resultButton.setTitle("Ladda upp", forState: .Normal)
            //cell.bucketlistButton.hidden = false
            cell.resultIcon.image = lockIcon
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

}
