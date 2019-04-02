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
//            "token": "EAAEIr7Xyej0BALiZB4dhMQcAF6ZBQye1clmVpKWUZCxM8NNA8ndoe2UUaJkZBZADk9ByZByCPKrDbhlrwJ22AMyoRSQ5TtQhbzPZBzO7AAgMIJccs32lY6bZB9nOldrnLW5uGkaCEtsoKuKeZAQ9bLTlgvRMg4hCNXKpwfdDxikzkERncGEGG1c8wc0bJD6eK2vd6EuURuqPcCYTg9ko7eEwcxVokJkxZBiyGK2nlLdHk1MwZDZD",
            "token": FBSDKAccessToken.current().tokenString!,
            "user_type": userType
        ]
        
        AF.request(url!, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { (response) in
            
            switch response.result {
                
            case .success(let value):
                
                let jsonData = JSON(value)
                print(jsonData)
                print(FBSDKAccessToken.current().tokenString!)
                
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
}
