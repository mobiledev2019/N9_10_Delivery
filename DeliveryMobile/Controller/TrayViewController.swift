//
//  TrayViewController.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 2/27/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TrayViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var tbvMeals: UITableView!
    @IBOutlet weak var viewTotal: UIView!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var tbAddress: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bAddPayment: UIButton!
    
    var locationManager : CLLocationManager!
    
    @IBAction func addPayment(_ sender: Any) {
        
        if tbAddress.text == "" {
            
            let alertController = UIAlertController(title: "No Address", message: "Address is required", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.tbAddress.becomeFirstResponder()
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            Tray.currentTray.address = tbAddress.text
            self.performSegue(withIdentifier: "AddPayment", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if Tray.currentTray.items.count == 0 {
            // Show message
            
            let lbEmptyTray = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
            lbEmptyTray.center = self.view.center
            lbEmptyTray.textAlignment = NSTextAlignment.center
            lbEmptyTray.text = "Your Tray is empty. Please select meal!"
            
            self.view.addSubview(lbEmptyTray)
        } else {
            // Display UI controller
            
            self.tbvMeals.isHidden = false
            self.viewTotal.isHidden = false
            self.viewAddress.isHidden = false
            self.bAddPayment.isHidden = false
            self.viewMap.isHidden = false
            
            loadMeals()
        }
        
        // Show current user location
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.map.showsUserLocation = true
            
        }
        
    }

    
    func loadMeals() {
        
        self.tbvMeals.reloadData()
        self.lbTotal.text = "$\(Tray.currentTray.getTotal())"
    }
}

extension TrayViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
    }
}

extension TrayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Tray.currentTray.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrayItemCell", for: indexPath) as! TrayViewCell
        
        let tray = Tray.currentTray.items[indexPath.row]
        cell.lbQty.text = "\(tray.qty)"
        cell.lbMealName.text = tray.meal.name
        cell.lbSubTotal.text = "$\(tray.meal.price! * Float(tray.qty))"
        
        return cell
    }
    
}
