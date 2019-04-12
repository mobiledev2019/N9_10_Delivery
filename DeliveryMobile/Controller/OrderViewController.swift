//
//  OrderViewController.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 2/27/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class OrderViewController: UIViewController {

    @IBOutlet weak var tbvMeal: UITableView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lbStatus: UILabel!
    
    var tray = [JSON]()
    
    var destination: MKPlacemark?
    var source: MKPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        getLatestOrder()
    }
    
    func getLatestOrder(){

        APIManager.shared.getLatestOrder { (json) in
            
            print(json)
            
            let order = json["order"]
            
            if let orderDetails = order["order_details"].array {

                self.lbStatus.text = order["status"].string!.uppercased()
                self.tray = orderDetails
                self.tbvMeal.reloadData()
            }
            
            let from = order["restaurant"]["address"].string!
            let to = order["address"].string!
            
            self.getLocation(from, "Restaurant", { (sou) in
                self.source = sou
                
                self.getLocation(to, "Customer", { (des) in
                    self.destination = des
                })
            })
        }
    }
}

extension OrderViewController: MKMapViewDelegate {
    
    // #1 - Delegate method of MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    // #2 - convert an address string to a location on the map
    func getLocation (_ address: String,_ title: String, _ completionHandler: @escaping (MKPlacemark) -> Void) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if (error != nil) {
                print("Error: ", error!)
            }
            
            if let placemark = placemarks?.first {
                
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                // Create Pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                dropPin.title = title
                
                self.map.addAnnotation(dropPin)
                completionHandler(MKPlacemark.init(placemark: placemark))
            }
        }
        
    }
}

extension OrderViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderViewCell
        
        let item = tray[indexPath.row]
        cell.lbQty.text = String(item["quantity"].int!)
        cell.lbMealName.text = item["meal"]["name"].string
        cell.lbSubTotal.text = "$\(String(item["sub_total"].float!))"
        
        return cell
    }
}
