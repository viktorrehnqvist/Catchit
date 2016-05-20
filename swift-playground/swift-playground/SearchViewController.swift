//
//  SearchViewController.swift
//  Catchit
//
//  Created by viktor johansson on 09/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Setup
    let postService = PostService()
    @IBOutlet weak var searchField: UITextField!        
    @IBOutlet weak var collectionView: UICollectionView!
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    var resultCount: Int = 1
    
    // MARK: Lifecycle
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
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
    
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.resultButton.layer.cornerRadius = 5
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: screenSize.width, height: 46)
    }
    
    // MARK: User Interaction
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func resignKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
