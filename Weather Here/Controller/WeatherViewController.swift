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
    func refreshGPS()
}

class WeatherViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!

    var delegate: WeatherControllerDelegate!
    var dataModel: WeatherDataModel!
    
    convenience init(_ delegate: WeatherControllerDelegate, dataModel: WeatherDataModel) {
        self.init()
        self.delegate = delegate
        self.dataModel = dataModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            delegate.refreshGPS()
        }
    }
    
    //MARK:- IBActions
    @IBAction func changeCityButtonTapped(_ sender: UIButton) {
        delegate.presentChangeCity()
    }

    //MARK:- UI
    ///Updates the UI using the data model.
    func updateUI() {
        DispatchQueue.main.async {
            SwiftSpinner.hide()
            self.temperatureLabel.text = "\(self.dataModel.temperature.decimalPlaces(1))°"
            self.windLabel.text = "\(self.dataModel.windSpeed.decimalPlaces(1)) m/s │ \(self.dataModel.windDirection)"
            self.weatherIcon.image = UIImage(named: self.dataModel.weatherIconName)
            self.cityLabel.text = self.dataModel.city
        }
    }
    
    /**
    Updates the UI with an error message.
 
    - parameter error: The error message to display.
    */
    func updateUI(with error: String) {
        DispatchQueue.main.async {
            SwiftSpinner.hide()
            self.cityLabel.text = error
        }
    }
}
