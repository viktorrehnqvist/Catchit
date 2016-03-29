//
//  NewViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 11/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

extension UILabel{
    
    func requiredHeight() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        return label.frame.height
    }
}

class NewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    var comments: [AnyObject] = []
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("commentCell", forIndexPath: indexPath) as! CommentsCollectionViewCell
        
        cell.label?.text = self.comments[indexPath.row] as? String
        cell.label.numberOfLines = 0
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let label = UILabel(frame: CGRectMake(0, 0, screenSize.width - 100, 0))
            label.text = self.comments[indexPath.row] as? String
            label.font = label.font.fontWithSize(12)
            // Calculates the required height for this comment depending on content
            var newLabelHeight = label.requiredHeight()
            if newLabelHeight < 30 {
                newLabelHeight = 35
            }
            let size = CGSize(width: screenSize.width, height: newLabelHeight + 10)
            return size
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 212)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 212)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        createComment()
        return true
    }
    
    
    // Lifting the view up
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    func createComment () {
        // Insert code to send comment to API
        let indexPath = NSIndexPath(forItem: self.comments.count, inSection: 0)
        comments.insert(textField.text!, atIndex: self.comments.count)
        collectionView.insertItemsAtIndexPaths([indexPath])
        textField.text = ""
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
