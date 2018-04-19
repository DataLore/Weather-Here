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
    @IBOutlet var windLabel: UILabel!
    @IBOutlet var weatherIcon: UIImageView!
    @IBOutlet var cityLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    private (set) var urlSession: URLSessionProtocol!
    private (set) var apiKey: String!
    private var urlRequest: URLRequest?
    private var responseData: Data?
    var weatherDataModel: WeatherDataModel!
    
    convenience init(_ urlSession: URLSession) {
        self.init()
        self.urlSession = urlSession
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataModel()
        configureInjection()
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
    func configureDataModel() {
        weatherDataModel = WeatherDataModel()
    }
    
    func configureInjection() {
        urlSession = URLSession.shared
    }
    
    func configureKey() {
        guard let plist = Bundle.main.url(forResource: "Keys", withExtension: "plist") else {fatalError()}
        guard let storedKey = NSDictionary(contentsOf: plist) as? [String: Any] else {fatalError()}
        guard let apiKey = storedKey["APIKey"] as? String else {fatalError()}
        self.apiKey = apiKey
    }
    
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
        requestComponents.queryItems?.append(URLQueryItem(name: "appid", value: apiKey))
        
        urlRequest = URLRequest(url: requestComponents.url!)
        urlRequest!.httpMethod = "GET"
    }
    
    /**
     Fetches weather data from the weather API.
     */
    func fetchWeatherData() {
        guard urlRequest != nil else {
            print("Unable to Locate API Request")
            return
        }
        let task = urlSession.dataTask(with: urlRequest!) { (data, response, error) in
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
    
    /**
     Processes weather data for the data model.
     
     - parameter data: Response data from weather API call.
     */
    func processWeatherData(_ data: Data) {
        guard let resultsJSON = try? JSONSerialization.jsonObject(with: data, options: []), let results = resultsJSON as? [String: Any]  else {
            print("Error Parsing Server Response")
            cityLabel.text = "Weather Unavailable"
            return
        }
        
        //Could use the Swift 4 codable but the data required is minimal
        if let main = results["main"] as? [String: Any] {
            if let temperature = main["temp"] as? Double {
                weatherDataModel.temperature = Int(temperature)
            }
        }
        if let wind = results["wind"] as? [String: Any] {
            if let windSpeed = wind["speed"] as? Double {
                weatherDataModel.windSpeed = Int(windSpeed)
            }
            if let windDirection = wind["deg"] as? Double {
                weatherDataModel.setWindDirection(windDirection)
            }
        }
        if let weather = results["weather"] as? [Any] {
            if let firstWeatherEntry = weather[0] as? [String: Any] {
                if let condition = firstWeatherEntry["id"] as? Int {
                    weatherDataModel.setWeatherIconName(condition)
                }
            }
        }
        if let city = results["name"] as? String {
            weatherDataModel.city = city
        }
        
        DispatchQueue.main.async {
            self.updateUI()
        }
    }

    //MARK:- UI
    ///Updates the UI useing the data model.
    func updateUI() {
        temperatureLabel.text = "\(weatherDataModel.temperature) °"
        windLabel.text = "\(weatherDataModel.windSpeed) kph / \(weatherDataModel.windDirection)"
        weatherIcon.image = UIImage(named: weatherDataModel.wetherIconName)
        cityLabel.text = weatherDataModel.city
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
        cityLabel.text = NSLocalizedString("lLocationUnavilable", comment: "")
    }
}

//MARK:- Change City Delegate
extension WeatherViewController: ChangeCityDelegate {
    /**
     Calls the API with a new city name.
     
     - parameter city: The new city name to supply to the API.
     */
    func changeCityName(city: String) {
        configureRequest(["q": city])
        fetchWeatherData()
    }
}

//MARK:- URLSession Dependancy Injection
protocol URLSessionProtocol: class {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return ((dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol)
    }
}
extension URLSessionDataTask: URLSessionDataTaskProtocol { }
