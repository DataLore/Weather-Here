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
    var windDirection: String = ""
    var city: String = ""
    var wetherIconName: String = ""
    
    /**
        Maps weather condition to icon given API condition code.
        - parameter condition: API condition code.
    */
    func setWeatherIconName(_ condition: Int) {
        switch (condition) {
        case 200...232:
            wetherIconName = "tstorm1"
            
        case 300...321:
            wetherIconName = "lightRain"
            
        case 500...531:
            wetherIconName = "shower1"
            
        case 600...622:
            wetherIconName = "snow1"
            
        case 701...771:
            wetherIconName = "fog"
            
        case 781:
            wetherIconName = "tstorm2"
            
        case 800:
            wetherIconName = "sunny"
            
        case 801...802:
            wetherIconName = "cloudy"
            
        case 803...804:
            wetherIconName = "overcast"
            
        case 900...902, 905...1000:
            wetherIconName = "tstorm2"
            
        case 903:
            wetherIconName = "snow2"
            
        case 904:
            wetherIconName = "sunny"
            
        default:
            wetherIconName = "unknown"
        }
    }
    
    func setWindDirection(_ degrees: Double) {
        switch(degrees) {
        case 0...11.25, 348.76...360:
            windDirection = "N"
        case 11.26...33.75:
            windDirection = "NNE"
        case 33.76...56.25:
            windDirection = "NE"
        case 56.26...78.75:
            windDirection = "ENE"
        case 78.76...101.25:
            windDirection = "E"
        case 101.26...123.75:
            windDirection = "ESE"
        case 123.76...146.25:
            windDirection = "SE"
        case 146.26...168.75:
            windDirection = "SEE"
        case 168.76...191.25:
            windDirection = "S"
        case 191.26...213.75:
            windDirection = "SWS"
        case 213.76...236.25:
            windDirection = "SW"
        case 236.26...258.76:
            windDirection = "WSW"
        case 258.77...281.25:
            windDirection = "W"
        case 281.26...303.75:
            windDirection = "WNW"
        case 303.76...326.25:
            windDirection = "NW"
        case 326.26...348.75:
            windDirection = "NNW"
        default:
            windDirection = ""
        }
    }
}

