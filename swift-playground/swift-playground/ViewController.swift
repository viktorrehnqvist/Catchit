//
//  ViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 12/02/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

@available(iOS 9.0, *)
class ViewController: UIViewController, PostServiceDelegate, CollectionViewCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var scrollView: UIScrollView!
    var stackView: UIStackView!
    var postImage: UIImageView!
    
    let postService = PostService()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    func setPosts(json: AnyObject) {
        print(json)
    }
    
    func displayComments(comments: AnyObject) {
        print(comments)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let appleProducts = ["Bestig ett berg", "Posera jämte en polis", "Klappa en igelkott", "Spring ett maraton", "Spring ett maraton"]
    
    let imageArray = [UIImage(named: "1"), UIImage(named: "2"), UIImage(named: "4"), UIImage(named: "3"), UIImage(named: "3") ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postService.getPosts()
        self.postService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.appleProducts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        
        cell.imageView?.image = self.imageArray[indexPath.row]
        cell.label?.text = self.appleProducts[indexPath.row]
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
    
    func displayCommentView(comments: AnyObject?) {
        self.performSegueWithIdentifier("showImage", sender: comments)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImage" {
            print(sender)
        }
    }

}



