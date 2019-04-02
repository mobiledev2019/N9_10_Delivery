//
//  Restaunrant.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 4/2/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import Foundation
import SwiftyJSON

class Restaurant {
    
    var id : Int?
    var name: String?
    var address: String?
    var logo: String?
    
    init(json: JSON) {
        
        self.id = json["id"].int
        self.name = json["name"].string
        self.address = json["address"].string
        self.logo = json["logo"].string
    }
}
