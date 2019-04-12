//
//  MealViewCell.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 4/3/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import UIKit

class MealViewCell: UITableViewCell {

    @IBOutlet weak var lbMealName: UILabel!
    @IBOutlet weak var lbShortDescription: UILabel!
    @IBOutlet weak var lbMealPrice: UILabel!
    @IBOutlet weak var imgMealImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
