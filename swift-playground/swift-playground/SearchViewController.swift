//
//  SearchViewController.swift
//  Catchit
//
//  Created by viktor johansson on 09/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate{

    // MARK: Setup
    let postService = PostService()
    @IBOutlet weak var searchField: UITextField!
    
    // MARK: Lifecycle
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
        searchField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    
    
    // MARK: User Interaction
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func resignKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
