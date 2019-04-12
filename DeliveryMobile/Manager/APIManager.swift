//
//  APIManager.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 3/21/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKLoginKit

class APIManager {
    
    static let shared = APIManager()
    
    let baseURL = NSURL(string: BASE_URL)
    
    var accessToken = ""
    var refreshToken = ""
    var expired = Date()
    
    //API to login
    func login(userType: String, completionHandler: @escaping (NSError?) -> Void) {
        
        let path = "api/social/convert-token/"
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "grant_type": "convert_token",
            "backend": "facebook",
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "token": FBSDKAccessToken.current().tokenString!,
            "user_type": userType
        ]
        
        AF.request(url!, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { (response) in
            
            switch response.result {
                
            case .success(let value):
                
                let jsonData = JSON(value)
                print(jsonData)
                
                self.accessToken = jsonData["access_token"].string!
                self.refreshToken = jsonData["refresh_token"].string!
                self.expired = Date().addingTimeInterval(TimeInterval(jsonData["expires_in"].int!))
                
                completionHandler(nil)
                break
                
            case .failure(let error):
                completionHandler(error as NSError)
                break
            }
        }
    }
    
    //API to logout
    func logout(completionHandler: @escaping (NSError?) -> Void) {
        let path = "api/social/revoke-token/"
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "token": self.accessToken
        ]
        
        AF.request(url!,method: .post,parameters: params,encoding: URLEncoding(), headers: nil).responseString { (response) in
            
            switch response.result {
            case .success:
                
                completionHandler(nil)
                break
                
            case .failure(let error):
                completionHandler(error as NSError)
                break
            }
        }
    }
    
    //API to refresh the token
    func refreshToken(completionHandler: @escaping () -> Void){
        
        let path = "api/social/refresh-token/"
        let url = baseURL?.appendingPathComponent(path)
        let params: [String: Any] = [
            "access_token" : self.accessToken,
            "refresh_token" : self.refreshToken
        ]
        
        if (Date() > self.expired){
            
            AF.request(url!, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).response(completionHandler: { (response) in
                
                switch response.result {
                case.success(let value):
                    let jsonData = JSON(value)
                    self.accessToken = jsonData["access_token"].string!
                    self.refreshToken = jsonData["refresh_token"].string!
                    self.expired = Date().addingTimeInterval(TimeInterval(jsonData["expires_in"].int!))
                    completionHandler()
                    break
                    
                case.failure:
                    break
                }
            })
        } else{
            completionHandler()
        }
    }
    
    // Request Server
    func requestServer(_ method: HTTPMethod,_ path: String,_ params: [String: Any]?,_ encoding: ParameterEncoding,_ completionHandler: @escaping (JSON) -> Void ) {
        
        let url = baseURL?.appendingPathComponent(path)
        
        refreshToken {
            
            AF.request(url!, method: method, parameters: params, encoding: encoding, headers: nil).responseJSON{ response in
                
                switch response.result {
                case .success(let value):
                    let jsonData = JSON(value)
                    completionHandler(jsonData)
                    break
                    
                case .failure:
                    completionHandler([])
                    break
                }
            }
        }
        
    }
    
    //**** CUSTOMER********* ///
    
    
    //API for getting Restaurant list
    func getRestaurants(completionHandler: @escaping (JSON?) -> Void) {
        
        let path = "api/customer/restaurants/"
        requestServer(.get, path, nil, URLEncoding(), completionHandler)
        
    }
    
    //API for getting Meal list
    func getMeals(restaurantID: Int, completionHandler: @escaping (JSON) -> Void){
        
        let path = "api/customer/meals/\(restaurantID)"
        requestServer(.get, path, nil, URLEncoding(), completionHandler)
    }
    
    // API creating new order
    
    func createOrder (stripteToken: String, completionHandler: @escaping (JSON) -> Void) {
        
        let path = "api/customer/order/add/"
        let simpleArray = Tray.currentTray.items
        let jsonArray = simpleArray.map { item in
            return ["meal_id": item.meal.id!,
                    "quantity": item.qty]
        }
        
        if JSONSerialization.isValidJSONObject(jsonArray) {
            
            do {
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                
                let params: [String: Any] = ["access_token": self.accessToken,
                                             "stripe_token": stripteToken,
                                             "restaurant_id": "\(Tray.currentTray.restaurant!.id!)",
                                             "order_details": dataString,
                                             "address": Tray.currentTray.address!
                ]
                
                requestServer(.post, path, params, URLEncoding(), completionHandler)
            }
            catch {
                print("JSON serialization failed: \(error)")
            }
        }
    }
    
    // API getting the latest order (Customer)
    func getLatestOrder(comletionHandler: @escaping (JSON) -> Void) {
        
        let path = "api/customer/order/latest/"
        let params: [String: Any] = ["access_token": self.accessToken]
        
        requestServer(.get, path, params, URLEncoding(), comletionHandler)
    }
    
    //**** DRIVERS********* ///
    
    // API for getting list of order ready
    func getDriverOrders(completionHandler: @escaping (JSON) -> Void) {
        
        let path = "api/driver/orders/ready/"
        requestServer(.get, path, nil, URLEncoding(), completionHandler)
    }
    
    // API Pick ready order
    func pickOrder(orderId: Int, completionHandler: @escaping (JSON) -> Void) {
        
        let path = "api/driver/orders/pick/"
        let params: [String: Any] = [
            "order_id": "\(orderId)",
            "access_token": self.accessToken
        ]
        requestServer(.post, path, params, URLEncoding(), completionHandler)
    }
}
