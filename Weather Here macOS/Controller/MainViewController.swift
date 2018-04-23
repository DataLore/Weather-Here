//
//  MainViewController.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import Cocoa

protocol MainViewControllerDelegate {
    func changeCityName(city: String)
    func changeCountryCode(code: String)
}

class MainViewController: NSViewController {

    @IBOutlet weak var cityLabel: NSTextField!
    @IBOutlet weak var temperatureLabel: NSTextField!
    @IBOutlet weak var windSpeedLabel: NSTextField!
    @IBOutlet weak var windDirectionLabel: NSTextField!
    @IBOutlet weak var weatherIcon: NSImageView!
    @IBOutlet weak var countryPicker: NSPopUpButton!
    @IBOutlet weak var cityNameSearch: NSSearchField!
    
    let measurementFormatter: MeasurementFormatter = {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.numberFormatter.maximumFractionDigits = 1
        return measurementFormatter
    }()
    
    var delegate: MainViewControllerDelegate!
    var weatherDataModel: WeatherDataModel!
    var changeCityDataModel: ChangeCityDataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func configureCountryPicker() {
        
    }
    
    private func createTemperatureText() -> String {
        return measurementFormatter.string(from: weatherDataModel.temperature)
    }
    
    private func createWindSpeedText() -> NSAttributedString {
        let wind = NSMutableAttributedString(string: "\(measurementFormatter.string(from: weatherDataModel.windSpeed)) ")
        let windImage = NSTextAttachment()
        windImage.image = NSImage(named: NSImage.Name(rawValue: "windIcon.png"))
        let windImageText = NSAttributedString(attachment: windImage)
        wind.append(windImageText)
        
        return wind
    }
    
    private func createWindDirectionText() -> NSAttributedString {
        let windDirection = NSMutableAttributedString(string: "\(weatherDataModel.windDirection) ")
        let windDirectionImage = NSTextAttachment()
        windDirectionImage.image = NSImage(named: NSImage.Name(rawValue: "compassIcon.png"))
        let windDirectionImageText = NSAttributedString(attachment: windDirectionImage)
        windDirection.append(windDirectionImageText)
        
        return windDirection
    }
    
    func updateUI(with error: String?) {
        
    }

}

