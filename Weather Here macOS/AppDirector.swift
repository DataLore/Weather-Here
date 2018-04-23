//
//  AppDirector.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import AppKit

class AppDirector: NSWindowController {
    
    var projectDirector: ProjectDirector!
    var dataModel: ProjectDataModel!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        projectDirector = ProjectDirector()
        projectDirector.delegate = self
        
        dataModel = projectDirector.projectDataModel
        
        let mainViewController = contentViewController as! MainViewController
        mainViewController.delegate = self
        mainViewController.weatherDataModel = projectDirector.weatherDataModel
        mainViewController.changeCityDataModel = projectDirector.changeCityDataModel
    }
}

extension AppDirector: ProjectDirectorDelegate {
    func updateUI(with error: String?) {
        let mainViewController = contentViewController as! MainViewController
        mainViewController.updateUI(with: error)
    }
}

extension AppDirector: MainViewDelegate {
    func changeCityName(city: String) {projectDirector.fetchAPIWeatherData(using: ["q": city])}
    func changeCountryCode(code: String) {projectDirector.changeCityDataModel.currentCountryCode = code}
}
