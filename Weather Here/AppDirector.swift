//
//  AppDirector.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class AppDirector: UIWindow {
    
    let dataModel: WeatherDataModel
    let mainStoryboard: UIStoryboard
    let weatherViewController: WeatherViewController
    
    lazy var changeCityViewController: ChangeCityViewController = {
        let changeCityViewController = self.mainStoryboard.instantiateViewController(withIdentifier: "changeCityView") as! ChangeCityViewController
        changeCityViewController.delegate = self
        return changeCityViewController
    }()
    
    lazy var apiKey: String = {
        return self.configureAPIKey()
    }()
    
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
    
    func configureRootViewController() {
        let rootViewController = UINavigationController(rootViewController: weatherViewController)
        rootViewController.isNavigationBarHidden = true
        self.rootViewController = rootViewController
    }
    
    func configureAPIKey(_ bundle: Bundle = Bundle.main) -> String {
        guard let plist = bundle.url(forResource: "Keys", withExtension: "plist") else {fatalError()}
        guard let storedKey = NSDictionary(contentsOf: plist) as? [String: Any] else {fatalError()}
        guard let apiKey = storedKey["APIKey"] as? String else {fatalError()}
        return apiKey
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
    func changeCityName(city: String) {
        weatherViewController.changeCityName(city: city)
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

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
