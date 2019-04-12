//
//  DriverOrderViewCell.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 4/12/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import UIKit

class DriverOrderViewCell: UITableViewCell {

    @IBOutlet weak var lbRestaurantName: UILabel!
    @IBOutlet weak var lbCustomerName: UILabel!
    @IBOutlet weak var lbCustomerAddress: UILabel!
    @IBOutlet weak var imgCustomerAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
