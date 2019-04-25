//
//  HourlyWeatherCollectionViewCell.swift
//  Weather
//
//  Created by Bilal Nawaz on 3/30/19.
//  Copyright © 2019 Bilal Nawaz. All rights reserved.
//

import UIKit

class HourlyWeatherCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var weatherConditionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
