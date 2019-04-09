//
//  PaymentViewController.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 2/27/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import UIKit
import Stripe

class PaymentViewController: UIViewController {

    
    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func placeOrder(_ sender: Any) {
        
        APIManager.shared.getLatestOrder { (json) in
            
            print(json["order"]["status"])
            if json["order"]["status"].stringValue == "" || json["order"]["status"] == "Delivered" {
                // Processing the payment and create an Order
                
                let card = self.cardTextField.cardParams
                
                STPAPIClient.shared().createToken(withCard: card, completion: { (token, error) in
                    
                    if let myError = error {
                        print("Error:", myError)
                    } else if let stripeToken = token {
                        
                        APIManager.shared.createOrder(stripteToken: stripeToken.tokenId) { (json) in
                            
                            Tray.currentTray.reset()
                            self.performSegue(withIdentifier: "ViewOrder", sender: self)
                        }
                    }
                })
                
            }
            else {
                // Showing alert message
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel)
                let okACtion = UIAlertAction(title: "Go to order", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "ViewOrder", sender: self)
                })
                
                let alertView = UIAlertController(title: "Already Order?", message: "Your current order isn't completed", preferredStyle: .alert)
                
                alertView.addAction(okACtion)
                alertView.addAction(cancelAction)
                
                self.present(alertView, animated: true, completion: nil)
                
            }
        }
    }
    
}
