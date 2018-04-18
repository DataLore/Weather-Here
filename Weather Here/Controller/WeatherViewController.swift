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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChangeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    //MARK:- Confgiure
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
    
    //MARK:- API
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
            self.processWeatherData(data)
        }
        task.resume()
    }
    
    func processWeatherData(_ data: Data) {
        guard let resultsJSON = try? JSONSerialization.jsonObject(with: data, options: []), let results = resultsJSON as? [String: Any]  else {
            print("Error Parsing Server Response")
            cityLabel.text = "Weather Unavailable"
            return
        }
        
        if let main = results["main"] as? [String: Any] {
            if let temperature = main["temp"] as? Double {
                weatherDataModel.temperature = Int(temperature)
            }
        }
        if let wind = results["wind"] as? [String: Any] {
            if let windSpeed = wind["speed"] as? Double {
                weatherDataModel.windSpeed = Int(windSpeed)
            }
        }
        if let weather = results["weather"] as? [Any] {
            if let firstWeatherEntry = weather[0] as? [String: Any] {
                if let condition = firstWeatherEntry["id"] as? Int {
                    weatherDataModel.condition = condition
                    weatherDataModel.updateWeatherIconName()
                }
            }
        }
        if let city = results["name"] as? String {
            weatherDataModel.city = city
        }
        
        updateUI()
    }

    //MARK:- UI
    func updateUI() {
        temperatureLabel.text = "\(weatherDataModel.temperature) °"
        windSpeedLabel.text = "\(weatherDataModel.windSpeed) kph"
        weatherIcon.image = UIImage(named: weatherDataModel.wetherIconName)
        cityLabel.text = weatherDataModel.city
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("Location: longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let locationData = ["lat": latitude, "lon": longitude]
            
            fetchWeatherData(parameters: locationData)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Failed with \(error)")
        cityLabel.text = "Location Unavilable"
    }
}

extension WeatherViewController: ChangeCityDelegate {
    func changeCityName(city: String) {
        fetchWeatherData(parameters: ["q": city])
    }
}
