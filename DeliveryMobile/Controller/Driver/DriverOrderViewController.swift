//
//  DriverOrderViewController.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 4/12/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import UIKit

class DriverOrderViewController: UITableViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    var orders = [DriverOrder]()
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadReadyOrder()
    }
    
    func loadReadyOrder() {
        
        Helpers.showActivityIndicator(activityIndicator, self.view)
        
        APIManager.shared.getDriverOrders { (json) in
            
            print(json)
            
            if json != nil {
                
                self.orders = []
                if let readyOrder = json["orders"].array {
                    for item in readyOrder {
                        let order = DriverOrder(json: item)
                        self.orders.append(order)
                    }
                }
                self.tableView.reloadData()
                Helpers.hideActivityIndicator(self.activityIndicator)
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverOrdersCell", for: indexPath) as! DriverOrderViewCell
        
        let order = orders[indexPath.row]
        cell.lbRestaurantName.text = order.restaurantName
        cell.lbCustomerName.text = order.customerName
        cell.lbCustomerAddress.text = order.customerAddress
        
        cell.imgCustomerAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: order.customerAvatar!)!))
        cell.imgCustomerAvatar.layer.cornerRadius = 50/2
        cell.imgCustomerAvatar.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let order = orders[indexPath.row]
        self.pickOrder(orderId: order.id!)
    }
    
    private func pickOrder(orderId: Int) {
        
        APIManager.shared.pickOrder(orderId: orderId) { (json) in
            
            print(json)
            
            if let status = json["status"].string {
                
                switch status {
                    
                case "failed":
                    // Show alert
                    let alertView = UIAlertController(title: "Error", message: json["error"].string!, preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)
                    
                    alertView.addAction(cancelAction)
                    self.present(alertView, animated: true, completion: nil)
                    
                default:
                    // Show success
                    let alertView = UIAlertController(title: nil, message: "Success", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Show my map", style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "CurrentDelivery", sender: self)
                    })
                    
                    alertView.addAction(okAction)
                    self.present(alertView, animated: true, completion: nil)
                }
            }
        }
    }

}
