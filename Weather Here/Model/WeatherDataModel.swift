//
//  WeatherDataModel.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import UIKit

class WeatherDataModel {
    
    var temperature: Int = 0
    var windSpeed: Int = 0
    var condition: Int = 0
    var city: String = ""
    var wetherIconName: String = ""
    
    /**
        Maps weather condition to icon given API condition code.
        - parameter condition: API condition code.
    */
    func updateWeatherIconName() {
        
        switch (condition) {
        case 200...232 :
            wetherIconName = "tstorm1"
            
        case 300...321 :
            wetherIconName = "lightRain"
            
        case 500...531 :
            wetherIconName = "shower1"
            
        case 600...622 :
            wetherIconName = "snow1"
            
        case 701...771 :
            wetherIconName = "fog"
            
        case 781 :
            wetherIconName = "tstorm2"
            
        case 800 :
            wetherIconName = "sunny"
            
        case 801...802 :
            wetherIconName = "cloudy"
            
        case 803...804 :
            wetherIconName = "overcast"
            
        case 900...902, 905...1000  :
            wetherIconName = "tstorm2"
            
        case 903 :
            wetherIconName = "snow2"
            
        case 904 :
            wetherIconName = "sunny"
            
        default :
            wetherIconName = "unknown"
        }
    }
}
