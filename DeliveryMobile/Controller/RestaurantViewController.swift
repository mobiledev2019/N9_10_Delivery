//
//  RestaurantViewController.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 2/26/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import UIKit

class RestaurantViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var searchRestaurant: UISearchBar!
    @IBOutlet weak var tbvRestaurant: UITableView!
    
    var restaurants = [Restaurant]()
    var filteredRestaurants = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        loadRestaurants()
    }
    
    func loadRestaurants(){
        APIManager.shared.getRestaurants { (json) in
            
            if json != nil {
                
                self.restaurants = []
                
                if let listRes = json!["restaurants"].array {
                    for item in listRes{
                        let restaurant = Restaurant(json: item)
                        self.restaurants.append(restaurant)
                    }
                    
                    self.tbvRestaurant.reloadData()
                }
            }
        }
    }
    func loadImage(imageView: UIImageView, urlString: String){
        let imgURL : URL = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: imgURL) { (data, response, error) in
            
            guard let data = data, error == nil else { return}
            
            DispatchQueue.main.async(execute: {
                imageView.image = UIImage(data: data)
            })
        }.resume()
    }
}

extension RestaurantViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredRestaurants = self.restaurants.filter({ (res: Restaurant) -> Bool in
            
            return res.name?.lowercased().range(of: searchText.lowercased()) != nil
        })
        
        self.tbvRestaurant.reloadData()
    }
}

extension RestaurantViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchRestaurant.text != "" {
            return self.filteredRestaurants.count
        }
        return self.restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestanrantViewCell
        
        let restaurant: Restaurant
        
        if searchRestaurant.text != "" {
            restaurant = filteredRestaurants[indexPath.row]
        } else {
            restaurant = restaurants[indexPath.row]
        }
        
        cell.lbRestaurantName.text = restaurant.name!
        cell.lbRestaurantAddress.text = restaurant.address!
        
        if let logoName = restaurant.logo {
            let url = "\(logoName)"
            loadImage(imageView: cell.imgRestaurantLogo, urlString: url)
        }
        return cell
    }
    
}
