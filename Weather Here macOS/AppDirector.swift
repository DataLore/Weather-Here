//
//  AppDirector.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import AppKit

@objc(AppDirector)
class AppDirector: NSApplication {
    
    let projectDirector: ProjectDirector
    let dataModel: ProjectDataModel
    
    lazy var mainViewController: MainViewController = {
        return mainWindow?.windowController?.contentViewController as! MainViewController
    }()
    
    override init() {
        //Project Director Setup
        projectDirector = ProjectDirector()
        dataModel = projectDirector.projectDataModel
        
        //Application Setup
        super.init()
        
        //Finalise Setup
        projectDirector.delegate = self
        mainViewController.delegate = self
        mainViewController.weatherDataModel = projectDirector.weatherDataModel
        mainViewController.changeCityDataModel = projectDirector.changeCityDataModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension AppDirector: ProjectDirectorDelegate {
    func updateUI(with error: String?) {
        mainViewController.updateUI(with: error)
    }
}

extension AppDirector: MainViewControllerDelegate {
    func changeCityName(city: String) {projectDirector.fetchAPIWeatherData(using: ["q": city])}
    func changeCountryCode(code: String) {projectDirector.changeCityDataModel.currentCountryCode = code}
}
