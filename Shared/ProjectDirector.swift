//
//  ProjectDirector.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import Foundation
#if os(iOS)
    import SwiftSpinner
#endif

protocol ProjectDirectorDelegate {
    func updateUI(with error: String?)
}

class ProjectDirector {

    let projectDataModel: ProjectDataModel
    let weatherDataModel: WeatherDataModel
    let changeCityDataModel: ChangeCityDataModel
    
    var delegate: ProjectDirectorDelegate!
    
    init(bundle: Bundle = Bundle.main) {
        projectDataModel = ProjectDataModel()
        weatherDataModel = WeatherDataModel()
        changeCityDataModel = ChangeCityDataModel()
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
        requestComponents.queryItems?.append(URLQueryItem(name: "appid", value: projectDataModel.apiKey))
        
        var urlRequest = URLRequest(url: requestComponents.url!)
        urlRequest.httpMethod = "GET"
        
        return urlRequest
    }
    
    /**
     Fetches weather data from the weather API.
     
     - warning: Performs asychronous network call.
     - parameter parameters: The location parameters supplied to the API.
     - parameter urlSession: The shared URLSession to use.
     */
    func fetchAPIWeatherData(using parameters: [String: String], urlSession: URLSession = URLSession.shared) {
        let urlRequest = createAPIRequest(using: parameters)
        
        #if os(iOS)
            SwiftSpinner.show("")
        #endif
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                let statusCode = (response as! HTTPURLResponse).statusCode
                print(error?.localizedDescription ?? "\(statusCode) Connection Error")
                self.delegate.updateUI(with: NSLocalizedString("lConnectionError", comment: ""))
                return
            }
            self.processAPIWeatherData(from: data)
        }
        task.resume()
    }
    
    /**
     Processes weather data for the data model.
     
     - parameter data: Response data from weather API call.
     */
    func processAPIWeatherData(from data: Data) {
        guard let resultsJSON = try? JSONSerialization.jsonObject(with: data, options: []), let results = resultsJSON as? [String: Any]  else {
            print("Error Parsing Server Response")
            delegate.updateUI(with: NSLocalizedString("lWeatherUnavailable", comment: ""))
            return
        }
        
        //Update weather model with temperature
        if let main = results["main"] as? [String: Any] {
            if let temperature = main["temp"] as? Double {
                weatherDataModel.temperature = Measurement(value: temperature, unit: UnitTemperature.celsius)
            }
            else {
                weatherDataModel.temperature = Measurement(value: 0.0, unit: UnitTemperature.celsius)
            }
        }
        
        //Update weather model with wind speed and direction
        if let wind = results["wind"] as? [String: Any] {
            if let windSpeed = wind["speed"] as? Double {
                weatherDataModel.windSpeed = Measurement(value: windSpeed, unit: UnitSpeed.metersPerSecond)
            }
            else {
                weatherDataModel.windSpeed = Measurement(value: 0.0, unit: UnitSpeed.metersPerSecond)
            }
            if let windDirection = wind["deg"] as? Double {
                weatherDataModel.setWindDirection(windDirection)
            }
            else {
                weatherDataModel.setWindDirection(0.0)
            }
        }
        
        //Update weather model with weather condition
        if let weather = results["weather"] as? [Any] {
            if let firstWeatherEntry = weather[0] as? [String: Any] {
                if let condition = firstWeatherEntry["id"] as? Int {
                    weatherDataModel.setWeatherIconName(condition)
                }
            }
        }
        
        //Update weather model with city name
        if let city = results["name"] as? String {
            weatherDataModel.city = city
        }
        
        delegate.updateUI(with: nil)
    }
}
