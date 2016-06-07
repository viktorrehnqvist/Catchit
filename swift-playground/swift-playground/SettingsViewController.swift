//
//  SettingsViewController.swift
//  Catchit
//
//  Created by viktor johansson on 07/06/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Tillbaka"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }

}
