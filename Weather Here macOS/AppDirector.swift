//
//  AppDirector.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import AppKit

@objc(AppDirector)
class AppDirector: NSApplication {
    
    let weatherDataModel: WeatherDataModel
    let changeCityDataModel: ChangeCityDataModel
    
    override init() {
        weatherDataModel = WeatherDataModel()
        changeCityDataModel = ChangeCityDataModel()
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
