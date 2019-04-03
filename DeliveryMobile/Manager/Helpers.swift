//
//  Helpers.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 4/3/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import Foundation

class Helpers {
    
    //Helper method to load image
    static func loadImage(_ imageView: UIImageView,_ urlString: String){
        let imgURL : URL = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: imgURL) { (data, response, error) in
            
            guard let data = data, error == nil else { return}
            
            DispatchQueue.main.async(execute: {
                imageView.image = UIImage(data: data)
            })
            }.resume()
    }
    
    //Helper method to show activityIndicator
    static func showActivityIndicator(_ activityIndicator: UIActivityIndicatorView,_ view: UIView){
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.color = UIColor.black
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
     //Helper method to hide activityIndicator
    static func hideActivityIndicator(_ activityIndicator: UIActivityIndicatorView){
        activityIndicator.stopAnimating()
    }

}
