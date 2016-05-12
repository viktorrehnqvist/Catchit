//
//  ChangePasswordViewController.swift
//  Catchit
//
//  Created by viktor johansson on 12/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, SettingsServiceDelegate {
    
    // MARK: Setup
    let settingsService = SettingsService()
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    
    // MARK: Lifecycle
    func setSettingsData(json: AnyObject) {
        if json["result"] as! Bool != false {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            let ac = UIAlertController(title: "Felaktigt lösenord", message: "Det angivna lösenordet är felaktigt. Försök igen.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsService.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: User Interaction
    @IBAction func saveSettings(sender: AnyObject) {
        settingsService.changePassword(currentPassword.text!, newPassword: newPassword.text!)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}