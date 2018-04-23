//
//  AppDirector.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftSpinner

class AppDirector: UIWindow {
    
    let projectDirector: ProjectDirector
    let dataModel: ProjectDataModel
    let locationManager: CLLocationManager
    let mainStoryboard: UIStoryboard
    let weatherViewController: WeatherViewController
    
    lazy var settingsViewController: SettingsViewController = {
        let settingsViewController = self.mainStoryboard.instantiateViewController(withIdentifier: "settingsView") as! SettingsViewController
        settingsViewController.delegate = self
        return settingsViewController
    }()
    
    lazy var changeCityViewController: ChangeCityViewController = {
        let changeCityViewController = self.mainStoryboard.instantiateViewController(withIdentifier: "changeCityView") as! ChangeCityViewController
        changeCityViewController.delegate = self
        changeCityViewController.dataModel = projectDirector.changeCityDataModel
        return changeCityViewController
    }()
    
    lazy var apiKey: String = {return self.configureAPIKey()}()
    
    init(bundle: Bundle = Bundle.main, screen: UIScreen = UIScreen.main) {
        //ProjectDirector Setup
        projectDirector = ProjectDirector()
        dataModel = projectDirector.projectDataModel
        
        //AppDirector Setup
        locationManager = CLLocationManager()
        mainStoryboard = UIStoryboard(name: "Main", bundle: bundle)
        weatherViewController = mainStoryboard.instantiateViewController(withIdentifier: "weatherView") as! WeatherViewController
        
        //UIWindow Setup
        super.init(frame: screen.bounds)
        
        //Finalise Setup
        projectDirector.delegate = self
        weatherViewController.dataModel = projectDirector.weatherDataModel
        weatherViewController.delegate = self
        configureLocationManager()
        configureRootViewController()
        self.makeKeyAndVisible()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Configure
    ///Configures the root controller as a UINavigationController.
    func configureRootViewController() {
        let rootViewController = UINavigationController(rootViewController: weatherViewController)
        rootViewController.isNavigationBarHidden = true
        self.rootViewController = rootViewController
    }
    
    ///Loads the API key from storage.
    func configureAPIKey(_ bundle: Bundle = Bundle.main) -> String {
        guard let plist = bundle.url(forResource: "Keys", withExtension: "plist") else {fatalError()}
        guard let storedKey = NSDictionary(contentsOf: plist) as? [String: Any] else {fatalError()}
        guard let apiKey = storedKey["APIKey"] as? String else {fatalError()}
        return apiKey
    }
    
    ///Configures Location Manager
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

//MARK:- App Data Model Extension
extension AppDirector: ProjectDirectorDelegate {
    func updateUI(with error: String?) {
        weatherViewController.updateUI(with: error)
    }
}

//MARK:- Settings Controller Extension
extension AppDirector: SettingsControllerDelegate {
    
}

//MARK:- Weather Controller Extension
extension AppDirector: WeatherControllerDelegate {
    func getAPIKey() -> String {return self.apiKey}
    func presentSettings() {self.rootViewController?.present(settingsViewController, animated: true, completion: nil)}
    func presentChangeCity() {self.rootViewController?.present(changeCityViewController, animated: true, completion: nil)}
    func refreshGPS() {configureLocationManager()}
}

//MARK:- Change City Controller Extension
extension AppDirector: ChangeCityControllerDelegate {
    func changeCityName(city: String) {projectDirector.fetchAPIWeatherData(using: ["q": city])}
    func changeCountryCode(code: String) {projectDirector.changeCityDataModel.currentCountryCode = code}
}

//MARK:- Location Manager Delegate
extension AppDirector: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let locationData = ["lat": latitude, "lon": longitude]
            
            projectDirector.fetchAPIWeatherData(using: locationData)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Failed with \(error)")
        weatherViewController.updateUI(with: NSLocalizedString("lLocationUnavailable", comment: ""))
    }
}
