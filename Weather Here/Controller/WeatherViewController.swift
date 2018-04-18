//
//  WeatherViewController.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var weatherIcon: UIImageView!
    @IBOutlet var cityLabel: UILabel!
    
    var weatherDataModel = WeatherDataModel()
    let locationManager = CLLocationManager()
    
    var apiKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureKey()
        configureLocationManager()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Confgiure Methods
    private func configureKey() {
        guard let plist = Bundle.main.url(forResource: "Keys", withExtension: "plist") else {fatalError()}
        guard let storedKey = NSDictionary(contentsOf: plist) as? [String: Any] else {fatalError()}
        guard let apiKey = storedKey["APIKey"] as? String else {fatalError()}
        self.apiKey = apiKey
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK:- Weather API
    func fetchWeatherData(parameters: [String:String]) {
        
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
        
        var request = URLRequest(url: requestComponents.url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                let statusCode = (response as! HTTPURLResponse).statusCode
                print(error?.localizedDescription ?? "\(statusCode) Connection Error")
                DispatchQueue.main.async {
                    self.cityLabel.text = "Connection Error"
                }
                return
            }
            
        }
        task.resume()
    }

}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }
}
