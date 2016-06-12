//
//  RegisterViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 03/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, AuthenticationServiceDelegate, UIScrollViewDelegate, UITextFieldDelegate {

    // MARK: Setup
    let authService = AuthenticationService()
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var marginTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
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
        loginButton.layer.cornerRadius = 5
        registerButton.layer.cornerRadius = 5
        marginTopConstraint.constant = 0.15 * screenSize.height
        emailLabel.delegate = self
        usernameLabel.delegate = self
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
    @IBAction func registerUser(sender: AnyObject?) {
        self.authService.registerUser(self.emailLabel.text!, password: self.passwordLabel.text!, username: self.usernameLabel.text!)
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
    
    

}
