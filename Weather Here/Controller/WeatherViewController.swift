//
//  WeatherViewController.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftSpinner

protocol WeatherControllerDelegate {
    func getAPIKey() -> String
    func presentChangeCity()
}

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    private var urlRequest: URLRequest?
    private var responseData: Data?

    var delegate: WeatherControllerDelegate!
    var dataModel: WeatherDataModel!
    
    convenience init(_ delegate: WeatherControllerDelegate, dataModel: WeatherDataModel) {
        self.init()
        self.delegate = delegate
        self.dataModel = dataModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
    }
    
    func changeCityName(city: String) {
        configureRequest(["q": city])
        fetchWeatherData()
    }
    
    //MARK:- IBActions
    @IBAction func changeCityButtonTapped(_ sender: UIButton) {
        delegate.presentChangeCity()
    }
    
    //MARK:- Confgiure
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK:- API
    /**
     Configures API request.
     
     - parameter parameters: The parameters supplied to the API.
     */
    func configureRequest(_ parameters: [String:String]) {
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
        requestComponents.queryItems?.append(URLQueryItem(name: "appid", value: delegate.getAPIKey()))
        
        urlRequest = URLRequest(url: requestComponents.url!)
        urlRequest!.httpMethod = "GET"
    }
    
    /**
     Fetches weather data from the weather API.
     */
    func fetchWeatherData(_ urlSession: URLSession = URLSession.shared) {
        guard urlRequest != nil else {
            print("Unable to Locate API Request")
            return
        }
        
        SwiftSpinner.show("")
        
        let task = urlSession.dataTask(with: urlRequest!) { (data, response, error) in
            guard let data = data, error == nil else {
                let statusCode = (response as! HTTPURLResponse).statusCode
                print(error?.localizedDescription ?? "\(statusCode) Connection Error")
                SwiftSpinner.hide()
                self.updateUIError(NSLocalizedString("lConnectionError", comment: ""))
                return
            }
            self.processWeatherData(data)
        }
        task.resume()
    }
    
    /**
     Processes weather data for the data model.
     
     - parameter data: Response data from weather API call.
     */
    func processWeatherData(_ data: Data) {
        guard let resultsJSON = try? JSONSerialization.jsonObject(with: data, options: []), let results = resultsJSON as? [String: Any]  else {
            print("Error Parsing Server Response")
            SwiftSpinner.hide()
            updateUIError(NSLocalizedString("lWeatherUnavailable", comment: ""))
            return
        }
        
        if let main = results["main"] as? [String: Any] {
            if let temperature = main["temp"] as? Double {
                dataModel.temperature = Int(temperature)
            }
        }
        if let wind = results["wind"] as? [String: Any] {
            if let windSpeed = wind["speed"] as? Double {
                dataModel.windSpeed = Int(windSpeed)
            }
            if let windDirection = wind["deg"] as? Double {
                dataModel.setWindDirection(windDirection)
            }
        }
        if let weather = results["weather"] as? [Any] {
            if let firstWeatherEntry = weather[0] as? [String: Any] {
                if let condition = firstWeatherEntry["id"] as? Int {
                    dataModel.setWeatherIconName(condition)
                }
            }
        }
        if let city = results["name"] as? String {
            dataModel.city = city
        }
        
        SwiftSpinner.hide()
        updateUI()
    }

    //MARK:- UI
    ///Updates the UI useing the data model.
    func updateUI() {
        DispatchQueue.main.async {
            self.temperatureLabel.text = "\(self.dataModel.temperature)°"
            self.windLabel.text = "\(self.dataModel.windSpeed) kph / \(self.dataModel.windDirection)"
            self.weatherIcon.image = UIImage(named: self.dataModel.weatherIconName)
            self.cityLabel.text = self.dataModel.city
        }
    }
    
    func updateUIError(_ error: String) {
        DispatchQueue.main.async {
            self.cityLabel.text = error
        }
    }
}

//MARK:- Location Manager Delegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let locationData = ["lat": latitude, "lon": longitude]
            
            configureRequest(locationData)
            fetchWeatherData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Failed with \(error)")
        updateUIError(NSLocalizedString("lLocationUnavailable", comment: ""))
    }
}

