//
//  RegisterViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 03/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, AuthenticationServiceDelegate {

    let authService = AuthenticationService()
    
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    func setAuthenticationData(json: AnyObject) {
        print(json)
        if json as! Bool == true {
            print("Registration complete")
            self.performSegueWithIdentifier("LoginFromRegistrationView", sender: nil)
        } else {
            print("Failed login")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authService.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerUser(sender: AnyObject?) {
        self.authService.registerUser(self.emailLabel.text!, username: self.usernameLabel.text!, password: self.passwordLabel.text!)
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
