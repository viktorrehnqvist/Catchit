//
//  RegisterViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 03/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, AuthenticationServiceDelegate {

    // MARK: Setup
    let authService = AuthenticationService()
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    // MARK: Lifecycle
    func setAuthenticationData(json: AnyObject) {
        if json as! Bool == true {
            self.performSegueWithIdentifier("LoginFromRegistrationView", sender: nil)
        } else {
            let ac = UIAlertController(title: "Felaktiga registreringsuppgifter", message: "De angivna registreringsuppgifterna är felaktiga. Försök igen.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authService.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: User Interaction
    @IBAction func registerUser(sender: AnyObject?) {
        self.authService.registerUser(self.emailLabel.text!, password: self.passwordLabel.text!, username: self.usernameLabel.text!)
    }
    
    @IBAction func resignKeyboard(sender: AnyObject) {
        sender.resignFirstResponder()
    }

}
