//
//  MealDetailsViewController.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 2/27/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import UIKit

class MealDetailsViewController: UIViewController {
    
    var meal: Meal?
    var qty = 1
    var restaurant: Restaurant?

    @IBOutlet weak var imgMeal: UIImageView!
    @IBOutlet weak var lbMealName: UILabel!
    @IBOutlet weak var lbMealShortDes: UILabel!
    
    @IBOutlet weak var lbQty: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    
    @IBAction func AddQty(_ sender: Any) {
        
        if qty < 99 {
            qty+=1
            lbQty.text = String(qty)
            
            if let price = meal?.price {
                lbTotal.text = "$\(price * Float(qty))"
            }
        }
    }
    
    @IBAction func removeQty(_ sender: Any) {
        
        if qty >= 2 {
            qty-=1
            lbQty.text = String(qty)
            
            if let price = meal?.price {
                lbTotal.text = "$\(price * Float(qty))"
            }
        }
    }
    
    @IBAction func addToTray(_ sender: Any) {
        
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        image.image = UIImage(named: "button_chicken")
        image.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height-100)
        self.view.addSubview(image)
        
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: { image.center = CGPoint(x: self.view.frame.width-40, y: 24) },
                       completion: { _ in
                        
            image.removeFromSuperview()
            
            let trayItem = TrayItem(meal: self.meal!, qty: self.qty)
            
            guard let trayRestaurant = Tray.currentTray.restaurant, let currentRestaurant = self.restaurant
                else {
                    // IF those not match
                Tray.currentTray.restaurant = self.restaurant
                Tray.currentTray.items.append(trayItem)
                return
                }
                        
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                    // if order same restaurant
                if trayRestaurant.id == currentRestaurant.id {
                    let inTray = Tray.currentTray.items.lastIndex(where: { (item) -> Bool in
                        
                        return item.meal.id! == trayItem.meal.id!
                        
                    })
                    
                    if let index = inTray{
                        
                        let alertView = UIAlertController(title: "Add more?",
                                                          message: "Your tray already have this meal. Do you want to add more?",
                                                          preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Add More", style: .default, handler: { (action: UIAlertAction!) in
                            
                            Tray.currentTray.items[index].qty += self.qty
                        })
                        alertView.addAction(okAction)
                        alertView.addAction(cancelAction)
                        
                        self.present(alertView, animated: true, completion: nil)
                    }
                    else {
                        Tray.currentTray.items.append(trayItem)
                    }
                }
                else { // if order diff restaurant
                    
                    let alertView = UIAlertController(title: "Start new tray?",
                                                      message: "You 're order from another restaurant. Would youy like to clear current tray",
                                                      preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "New Tray", style: .default, handler: { (action: UIAlertAction!) in
                        
                        Tray.currentTray.items = []
                        Tray.currentTray.items.append(trayItem)
                        Tray.currentTray.restaurant = self.restaurant
                    })
                    alertView.addAction(okAction)
                    alertView.addAction(cancelAction)
                    
                    self.present(alertView, animated: true, completion: nil)
                }

        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMeal()
    }
    
    func loadMeal(){
        
        if let price = meal?.price {
            lbTotal.text = "$\(price)"
        }
        
        lbMealName.text = meal?.name
        lbMealShortDes.text = meal?.short_description
        
        if let imageUrl = meal?.image {
            Helpers.loadImage(imgMeal, "\(imageUrl)")
        }
    }

}
