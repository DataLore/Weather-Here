//
//  AppDirector.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import Foundation
import UIKit

class AppDirector: UIWindow {
    
    let mainStoryboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
    let weatherViewController: WeatherViewController
    
    lazy var changeCityViewController: ChangeCityViewController = {
        self.mainStoryboard.instantiateViewController(withIdentifier: "changeCityView") as! ChangeCityViewController
    }()
    
    init() {
        //AppDirector Setup
        weatherViewController = mainStoryboard.instantiateViewController(withIdentifier: "weatherView") as! WeatherViewController
        
        //UIWindow Setup
        super.init(frame: UIScreen.main.bounds)
        
        //Finalise Setup
        configureRootViewController()
        self.makeKeyAndVisible()
    }
    
    func configureRootViewController() {
        let rootViewController = UINavigationController(rootViewController: weatherViewController)
        rootViewController.isNavigationBarHidden = true
        
        self.rootViewController = rootViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
