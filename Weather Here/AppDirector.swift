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

    let dataModel: WeatherDataModel
    let locationManager: CLLocationManager
    let mainStoryboard: UIStoryboard
    let weatherViewController: WeatherViewController
    
    lazy var changeCityViewController: ChangeCityViewController = {
        let changeCityViewController = self.mainStoryboard.instantiateViewController(withIdentifier: "changeCityView") as! ChangeCityViewController
        changeCityViewController.delegate = self
        return changeCityViewController
    }()
    
    lazy var apiKey: String = {return self.configureAPIKey()}()
    lazy var countryCodes: ([String], [String]) = {return self.configureCountryCodes()}()
    
    init(bundle: Bundle = Bundle.main, screen: UIScreen = UIScreen.main) {
        //AppDirector Setup
        dataModel = WeatherDataModel()
        locationManager = CLLocationManager()
        mainStoryboard = UIStoryboard(name: "Main", bundle: bundle)
        weatherViewController = mainStoryboard.instantiateViewController(withIdentifier: "weatherView") as! WeatherViewController
        
        //UIWindow Setup
        super.init(frame: screen.bounds)
        
        //Finalise Setup
        weatherViewController.dataModel = dataModel
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
    
    ///Configures Location Manager
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK:- API
    /**
     Fetches weather data from the weather API.
     
     - warning: Performs asychronous network call.
     - parameter parameters: The location parameters supplied to the API.
     - parameter urlSession: The shared URLSession to use.
     */
    func fetchAPIWeatherData(using parameters: [String: String], urlSession: URLSession = URLSession.shared) {
        let urlRequest = createAPIRequest(using: parameters)
        
        SwiftSpinner.show("")
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                let statusCode = (response as! HTTPURLResponse).statusCode
                print(error?.localizedDescription ?? "\(statusCode) Connection Error")
                self.weatherViewController.updateUI(with: NSLocalizedString("lConnectionError", comment: ""))
                return
            }
            self.processAPIWeatherData(from: data)
        }
        task.resume()
    }
    
    /**
     Creates an API request for the weather API.
     
     - parameter parameters: The location parameters supplied to the API.
     - returns: The url request for the weather API.
     */
    func createAPIRequest(using parameters: [String:String]) -> URLRequest {
        var requestComponents = URLComponents()
        requestComponents.scheme = "http"
        requestComponents.host = "api.openweathermap.org"
        requestComponents.path = "/data/2.5/weather"
        requestComponents.queryItems = []
        for parameter in parameters {
            let queryItem = URLQueryItem(name: parameter.key, value: parameter.value)
            requestComponents.queryItems?.append(queryItem)
        }
        requestComponents.queryItems?.append(URLQueryItem(name: "units", value: "metric"))
        requestComponents.queryItems?.append(URLQueryItem(name: "appid", value: apiKey))
        
        var urlRequest = URLRequest(url: requestComponents.url!)
        urlRequest.httpMethod = "GET"
        
        return urlRequest
    }
    
    /**
     Processes weather data for the data model.
     
     - parameter data: Response data from weather API call.
     */
    func processAPIWeatherData(from data: Data) {
        guard let resultsJSON = try? JSONSerialization.jsonObject(with: data, options: []), let results = resultsJSON as? [String: Any]  else {
            print("Error Parsing Server Response")
            weatherViewController.updateUI(with: NSLocalizedString("lWeatherUnavailable", comment: ""))
            return
        }
        
        //Update model with temperature
        if let main = results["main"] as? [String: Any] {
            if let temperature = main["temp"] as? Double {
                dataModel.temperature = Int(temperature)
            }
        }
        
        //Update model with wind speed and direction
        if let wind = results["wind"] as? [String: Any] {
            if let windSpeed = wind["speed"] as? Double {
                dataModel.windSpeed = Int(windSpeed)
            }
            else {
                dataModel.windSpeed = 0
            }
            if let windDirection = wind["deg"] as? Double {
                dataModel.setWindDirection(windDirection)
            }
            else {
                dataModel.setWindDirection(0.0)
            }
        }
        
        //Update model with weather condition
        if let weather = results["weather"] as? [Any] {
            if let firstWeatherEntry = weather[0] as? [String: Any] {
                if let condition = firstWeatherEntry["id"] as? Int {
                    dataModel.setWeatherIconName(condition)
                }
            }
        }
        
        //Update model with city name
        if let city = results["name"] as? String {
            dataModel.city = city
        }
        
        weatherViewController.updateUI()
    }
}

//MARK:- Weather Controller Extension
extension AppDirector: WeatherControllerDelegate {
    func getAPIKey() -> String {return self.apiKey}
    func presentChangeCity() {self.rootViewController?.present(changeCityViewController, animated: true, completion: nil)}
}

//MARK:- Change City Controller Extension
extension AppDirector: ChangeCityControllerDelegate {
    func getCountryKeys() -> [String] {return countryCodes.0}
    func getCountryValues() -> [String] {return countryCodes.1}
    func changeCityName(city: String) {fetchAPIWeatherData(using: ["q": city])}
        //weatherViewController.changeCityName(city: city)
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
            
            fetchAPIWeatherData(using: locationData)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Failed with \(error)")
        weatherViewController.updateUI(with: NSLocalizedString("lLocationUnavailable", comment: ""))
    }
}
