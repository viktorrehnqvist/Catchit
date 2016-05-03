//
//  LoginViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 03/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, AuthenticationServiceDelegate {
    
    let authService = AuthenticationService()
    
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    func setAuthenticationData(json: AnyObject) {
        if json as! Bool == true {
            self.performSegueWithIdentifier("LoginFromLoginView", sender: nil)
        } else {
            print("Failed login")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authService.delegate = self
        print("Login view")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginUser(sender: AnyObject?) {
        self.authService.loginUser(self.emailLabel.text!, password: self.passwordLabel.text!)
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
