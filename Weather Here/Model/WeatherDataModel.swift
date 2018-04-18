//
//  WeatherDataModel.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import UIKit

class WeatherDataModel {
    
    var temperature: Int = 0
    var condition: Int = 0
    var city: String = ""
    var wetherIconName: String = ""
    
    /**
        Maps weather condition to icon given API condition code.
        - parameter condition: API condition code.
        - returns: Icon name.
    */
    func updateWeatherIcon(condition: Int) -> String {
        
        switch (condition) {
        case 200...232 :
            return "tstorm1"
            
        case 300...321 :
            return "lightRain"
            
        case 500...531 :
            return "shower1"
            
        case 600...622 :
            return "snow1"
            
        case 701...771 :
            return "fog"
            
        case 781 :
            return "tstorm2"
            
        case 800 :
            return "sunny"
            
        case 801...802 :
            return "cloudy"
            
        case 803...804 :
            return "overcast"
            
        case 900...902, 905...1000  :
            return "tstorm2"
            
        case 903 :
            return "snow2"
            
        case 904 :
            return "sunny"
            
        default :
            return "unknown"
        }
    }
}
