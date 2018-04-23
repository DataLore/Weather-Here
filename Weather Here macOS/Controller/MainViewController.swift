//
//  MainViewController.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import Cocoa

protocol MainViewDelegate {
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
    
    var delegate: MainViewDelegate!
    var weatherDataModel: WeatherDataModel!
    var changeCityDataModel: ChangeCityDataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        configureElements()
        configureCountryPicker()
    }

    override var representedObject: Any? {
        didSet {

        }
    }

    @IBAction func countrySelectionChanged(_ sender: NSPopUpButton) {
        guard let newCountrySelection = sender.titleOfSelectedItem else {return}
        changeCityDataModel.currentCountryCode = changeCityDataModel.countryTitlesDictonary[newCountrySelection]!
    }
    
    private func configureElements() {
        cityLabel.stringValue = ""
        temperatureLabel.stringValue = ""
        windSpeedLabel.stringValue = ""
        windDirectionLabel.stringValue = ""
    }
    
    private func configureCountryPicker(locale: Locale = Locale.current) {
        countryPicker.addItems(withTitles: changeCityDataModel.countryCodes.titles)
        guard let region = locale.regionCode else {return}
        for i in 0..<changeCityDataModel.countryCodes.codes.count {
            if changeCityDataModel.countryCodes.codes[i] == region {
                changeCityDataModel.currentCountryCode = region
                countryPicker.selectItem(at: i)
                return
            }
        }
    }
    
    private func createTemperatureText() -> String {
        return measurementFormatter.string(from: weatherDataModel.temperature)
    }
    
    private func createWindSpeedText() -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        let wind = NSMutableAttributedString(string: "\(measurementFormatter.string(from: weatherDataModel.windSpeed)) ", attributes: [kCTParagraphStyleAttributeName as NSAttributedStringKey : style])
        let windImage = NSTextAttachment()
        let attachmentCell = NSTextAttachmentCell(imageCell: NSImage(named: NSImage.Name(rawValue: "windIcon")))
        windImage.attachmentCell = attachmentCell
        let windImageText = NSAttributedString(attachment: windImage)
        wind.append(windImageText)
        return wind
    }
    
    private func createWindDirectionText() -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        let windDirection = NSMutableAttributedString(string: "\(weatherDataModel.windDirection) ",  attributes: [kCTParagraphStyleAttributeName as NSAttributedStringKey : style])
        let windDirectionImage = NSTextAttachment()
        let attachmentCell = NSTextAttachmentCell(imageCell: NSImage(named: NSImage.Name(rawValue: "compassIcon")))
        windDirectionImage.attachmentCell = attachmentCell
        let windDirectionImageText = NSAttributedString(attachment: windDirectionImage)
        windDirection.append(windDirectionImageText)
        return windDirection
    }
    
    func updateUI(with error: String?) {
        if let error = error {
            DispatchQueue.main.async {
                self.cityLabel.stringValue = error
            }
        }
        else {
            DispatchQueue.main.async {
                self.cityLabel.stringValue = self.weatherDataModel.city
                self.temperatureLabel.stringValue = self.createTemperatureText()
                self.windSpeedLabel.attributedStringValue = self.createWindSpeedText()
                self.windDirectionLabel.attributedStringValue = self.createWindDirectionText()
                self.weatherIcon.image = NSImage(named: NSImage.Name(rawValue: self.weatherDataModel.weatherIconName))
            }
        }
    }

}

extension MainViewController: NSSearchFieldDelegate {
    override func controlTextDidEndEditing(_ obj: Notification) {
        guard let searchField = obj.object as? NSSearchField else {return}
        let city = searchField.stringValue.trimmingCharacters(in: .whitespaces).appending(", \(changeCityDataModel.currentCountryCode)")
        delegate.changeCityName(city: city)
    }
}

