//
//  ChangeUsernameViewController.swift
//  Catchit
//
//  Created by viktor johansson on 12/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class ChangeUsernameViewController: UIViewController, SettingsServiceDelegate {
    
    // MARK: Setup
    let settingsService = SettingsService()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var username: UITextField!
    
    // MARK: Lifecycle
    func setSettingsData(json: AnyObject) {
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = (userDefaults.objectForKey("name") as! String)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: User Interaction
    @IBAction func saveSettings(sender: AnyObject) {
        settingsService.changeUsername(username.text!)
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    // MARK: - Navigation

    // MARK: Additional Helpers
}
