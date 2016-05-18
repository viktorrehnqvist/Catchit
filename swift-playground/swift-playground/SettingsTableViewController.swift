//
//  SettingsTableViewController.swift
//  Catchit
//
//  Created by viktor johansson on 18/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: Setup
    @IBOutlet weak var shareGpsSwitch: UISwitch!
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Layout
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    // MARK: User Interaction
    @IBAction func shareGps(sender: AnyObject) {
        print(shareGpsSwitch)
    }
 
    @IBAction func logOut(sender: AnyObject) {
        let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as UIViewController
        rootVC.view.frame = UIScreen.mainScreen().bounds
        UIView.transitionWithView(self.view.window!, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            self.view.window!.rootViewController = rootVC
            }, completion: nil)
    }
    
}