//
//  ViewController.swift
//  HealtRate
//
//  Created by duruldalkanat on 6/2/17.
//  Copyright © 2017 duruldalkanat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let healthKitManager = HealthKitManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        healthKitManager.authorizeHealthKit { (success, error) in
            print("Was healthkit successful? \(success)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

