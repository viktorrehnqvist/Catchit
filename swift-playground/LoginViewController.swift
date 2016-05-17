//
//  LoginViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 03/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, AuthenticationServiceDelegate, UIScrollViewDelegate, UITextFieldDelegate{
    
    // MARK: Setup
    let authService = AuthenticationService()
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var marginTopConstraint: NSLayoutConstraint!
    
     // MARK: Lifecycle
    func setAuthenticationData(json: AnyObject) {
        if json as! Bool == true {
            self.performSegueWithIdentifier("LoginFromLoginView", sender: nil)
        } else {
            let ac = UIAlertController(title: "Felaktiga inloggningsuppgifter", message: "De angivna inloggningsuppgifterna är felaktiga. Försök igen.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        marginTopConstraint.constant = 0.15 * screenSize.height
        emailLabel.delegate = self
        passwordLabel.delegate = self
        scrollView.delegate = self
        self.authService.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: User Interaction
    @IBAction func loginUser(sender: AnyObject?) {
        self.authService.loginUser(self.emailLabel.text!, password: self.passwordLabel.text!)
    }
    
    @IBAction func resignKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
        if screenSize.height < 500 {
            logo.hidden = false
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if screenSize.height < 500 {
            logo.hidden = true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Additional Helpers

}
