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
    
    private func createWindSpeedText() -> NSAttributedString {
        let wind = NSMutableAttributedString(string: "\(String(format: "%.1f", self.dataModel.windSpeed)) m/s ")
        let windImage = NSTextAttachment()
        windImage.image = UIImage(named: "windIcon.png")
        let windImageText = NSAttributedString(attachment: windImage)
        wind.append(windImageText)
        
        return wind
    }
    
    private func createWindDirectionText() -> NSAttributedString {
        let windDirection = NSMutableAttributedString(string: "\(self.dataModel.windDirection) ")
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
    ///Updates the UI using the data model.
    func updateUI() {
        DispatchQueue.main.async {
            SwiftSpinner.hide()
            self.temperatureLabel.text = "\(String(format: "%.1f", self.dataModel.temperature))°"
            self.windSpeedLabel.attributedText = self.createWindSpeedText()
            self.windDirectionLabel.attributedText = self.createWindDirectionText()
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
