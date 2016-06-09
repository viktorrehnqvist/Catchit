//
//  ChangeAvatarViewController.swift
//  Catchit
//
//  Created by viktor johansson on 12/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import MobileCoreServices

class ChangeAvatarViewController: UIViewController, SettingsServiceDelegate, UserServiceDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Setup
    let settingsService = SettingsService()
    let userService = UserService()
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: Lifecycle
    func setSettingsData(json: AnyObject) {
    }
    
    func setUserData(json: AnyObject, follow: Bool) {
        fetchDataFromUrlToUserAvatar((json["avatar_url"] as! String))
    }
    
    func updateUserData(json: AnyObject) {
    }
    
    func setNoticeData(notSeenNoticeCount: Int) {
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        roundButtons()
        self.userService.delegate = self
        self.settingsService.delegate = self
        self.userService.getCurrentUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    func roundButtons() {
        pickImageButton.layer.cornerRadius = 5
        saveButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
    }
    
    // MARK: User Interaction
    @IBAction func uploadAvatar(sender: AnyObject) {
        let existingOrNewMediaController = UIAlertController(title: "Inlägg", message: "Välj från bibliotek eller ta bild", preferredStyle: .Alert)
        existingOrNewMediaController.addAction(UIAlertAction(title: "Välj från bibliotek", style: .Default) { (UIAlertAction) in
            self.useLibrary()
            })
        existingOrNewMediaController.addAction(UIAlertAction(title: "Ta bild", style: .Default) { (UIAlertAction) in
            self.useCamera()
            })
        existingOrNewMediaController.addAction(UIAlertAction(title: "Avbryt", style: .Cancel, handler: nil))
        self.presentViewController(existingOrNewMediaController, animated: true, completion: nil)
    }

    @IBAction func saveChanges(sender: AnyObject) {
        let image = avatar.image
        let imageData: NSData = UIImagePNGRepresentation(image!)!
        settingsService.uploadImage(imageData)
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: Additional Helpers
    func useLibrary() {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        imageFromSource.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imageFromSource.mediaTypes = [kUTTypeImage as String]
        self.presentViewController(imageFromSource, animated: true, completion: nil)
    }
    
    func useCamera() {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        imageFromSource.sourceType = UIImagePickerControllerSourceType.Camera
        imageFromSource.mediaTypes = [kUTTypeImage as String]
        self.presentViewController(imageFromSource, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType]
        if mediaType!.isEqualToString(kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            let resizedImage = resizeImage(image!, newSize: 259)
            avatar.image = resizedImage
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newSize: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(newSize, newSize))
        image.drawInRect(CGRectMake(0, 0, newSize, newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func fetchDataFromUrlToUserAvatar(fetchUrl: String) {
        let url = NSURL(string: self.url + fetchUrl)!
        let data = NSData(contentsOfURL:url)
        let image = UIImage(data: data!)
        self.avatar.image = image
        self.avatar.hidden = false
    }

}




