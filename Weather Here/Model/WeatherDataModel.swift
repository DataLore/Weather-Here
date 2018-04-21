//
//  WeatherDataModel.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import UIKit

class WeatherDataModel {

    ///Current temperature.
    var temperature: Double = 0.0
    ///Current wind speed.
    var windSpeed: Double = 0.0
    ///Current city.
    var city: String = ""
    ///Current wind direction given as a compass direction.
    private(set) var windDirection: String = ""
    ///Current weather condtion represented as an icon name.
    private(set) var weatherIconName: String = ""
    
    /**
     Computes and sets weather icon from API weather condition code.
     
     - parameter condition: API condition code.
    */
    func setWeatherIconName(_ condition: Int) {
        switch (condition) {
        case 200...232:
            weatherIconName = "tstorm1"
        case 300...321:
            weatherIconName = "lightRain"
        case 500...531:
            weatherIconName = "shower1"
        case 600...622:
            weatherIconName = "snow1"
        case 701...771:
            weatherIconName = "fog"
        case 781:
            weatherIconName = "tstorm2"
        case 800:
            weatherIconName = "sunny"
        case 801...802:
            weatherIconName = "cloudy"
        case 803...804:
            weatherIconName = "overcast"
        case 900...902, 905...1000:
            weatherIconName = "tstorm2"
        case 903:
            weatherIconName = "snow2"
        case 904:
            weatherIconName = "sunny"
        default:
            weatherIconName = "unknown"
        }
    }
    
    /**
     Computes and sets the wind direction from degrees.
     
     - parameter degrees: Degrees indicating direction.
     */
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
            windDirection = "SSE"
        case 168.76...191.25:
            windDirection = "S"
        case 191.26...213.75:
            windDirection = "SSW"
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

