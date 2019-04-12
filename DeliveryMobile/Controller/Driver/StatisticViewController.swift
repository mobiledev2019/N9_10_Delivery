//
//  StatisticViewController.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 4/12/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import UIKit

class StatisticViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

    }
}
