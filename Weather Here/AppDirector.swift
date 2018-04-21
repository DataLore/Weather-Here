//
//  AppDirector.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import UIKit
import CoreLocation

class AppDirector: UIWindow {
    
    let dataModel: WeatherDataModel
    let mainStoryboard: UIStoryboard
    let weatherViewController: WeatherViewController
    
    lazy var changeCityViewController: ChangeCityViewController = {
        let changeCityViewController = self.mainStoryboard.instantiateViewController(withIdentifier: "changeCityView") as! ChangeCityViewController
        changeCityViewController.delegate = self
        return changeCityViewController
    }()
    
    lazy var apiKey: String = {return self.configureAPIKey()}()
    lazy var countryCodes: ([String], [String]) = {return self.configureCountryCodes()}()
    
    init() {
        //AppDirector Setup
        dataModel = WeatherDataModel()
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        weatherViewController = mainStoryboard.instantiateViewController(withIdentifier: "weatherView") as! WeatherViewController
        
        //UIWindow Setup
        super.init(frame: UIScreen.main.bounds)
        
        //Finalise Setup
        weatherViewController.delegate = self
        configureRootViewController()
        self.makeKeyAndVisible()
    }
    
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
    
    ///Loads the country codes from storage.
    func configureCountryCodes(_ bundle: Bundle = Bundle.main) -> ([String], [String]) {
        var countryCodes = ([String](), [String]())
        guard let url = bundle.url(forResource: "countryCodes", withExtension: "json") else {fatalError()}
        guard let data = try? Data(contentsOf: url) else {fatalError()}
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []), let results = json as? [Any] else {fatalError()}
        for countryCode in results {
            guard let countryCode = countryCode as? [String: String] else {continue}
            countryCodes.0.append(countryCode["Code"]!)
            countryCodes.1.append(countryCode["Name"]!)
        }
        return countryCodes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AppDirector: WeatherControllerDelegate {
    func getAPIKey() -> String {return self.apiKey}
    func presentChangeCity() {self.rootViewController?.present(changeCityViewController, animated: true, completion: nil)}
}

extension AppDirector: ChangeCityControllerDelegate {
    func getCountryKeys() -> [String] {return countryCodes.0}
    func getCountryValues() -> [String] {return countryCodes.1}
    func changeCityName(city: String) {weatherViewController.changeCityName(city: city)}
}
