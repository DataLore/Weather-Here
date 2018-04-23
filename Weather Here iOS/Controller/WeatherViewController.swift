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
    func presentSettings()
    func presentChangeCity()
    func refreshGPS()
}

class WeatherViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirectionLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!

    let measurementFormatter: MeasurementFormatter = {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.numberFormatter.maximumFractionDigits = 1
        return measurementFormatter
    }()
    
    var delegate: WeatherControllerDelegate!
    var dataModel: WeatherDataModel!
    
    convenience init(_ delegate: WeatherControllerDelegate, dataModel: WeatherDataModel) {
        self.init()
        self.delegate = delegate
        self.dataModel = dataModel
    }
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            delegate.refreshGPS()
        }
    }
    
    private func createTemperatureText() -> String {
        return measurementFormatter.string(from: dataModel.temperature)
    }
    
    private func createWindSpeedText() -> NSAttributedString {
        let wind = NSMutableAttributedString(string: "\(measurementFormatter.string(from: dataModel.windSpeed)) ")
        let windImage = NSTextAttachment()
        windImage.image = UIImage(named: "windIcon.png")
        let windImageText = NSAttributedString(attachment: windImage)
        wind.append(windImageText)
        
        return wind
    }
    
    private func createWindDirectionText() -> NSAttributedString {
        let windDirection = NSMutableAttributedString(string: "\(dataModel.windDirection) ")
        let windDirectionImage = NSTextAttachment()
        windDirectionImage.image = UIImage(named: "compassIcon.png")
        let windDirectionImageText = NSAttributedString(attachment: windDirectionImage)
        windDirection.append(windDirectionImageText)
        
        return windDirection
    }
    
    //MARK:- IBActions
    @IBAction func settingsButtonTapped(_ sender: UIButton) {delegate.presentSettings()}
    @IBAction func changeCityButtonTapped(_ sender: UIButton) {delegate.presentChangeCity()}

    //MARK:- UI
    /**
    Updates the UI with or without an error message.
 
    - parameter error: The error message to display if there is one.
    */
    func updateUI(with error: String?) {
        if let error = error {
            DispatchQueue.main.async {
                SwiftSpinner.hide()
                self.cityLabel.text = error
            }
        }
        else {
            DispatchQueue.main.async {
                SwiftSpinner.hide()
                self.temperatureLabel.text = self.createTemperatureText()
                self.windSpeedLabel.attributedText = self.createWindSpeedText()
                self.windDirectionLabel.attributedText = self.createWindDirectionText()
                self.weatherIcon.image = UIImage(named: self.dataModel.weatherIconName)
                self.cityLabel.text = self.dataModel.city
            }
        }
    }
}
