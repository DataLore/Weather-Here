//
//  ChangeCityViewController.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import UIKit

protocol ChangeCityDelegate {
    func changeCityName(city: String)
}

class ChangeCityViewController: UIViewController {

    @IBOutlet var changeCityTextfield: UITextField!
    @IBOutlet var warningLabel: UILabel!
    @IBOutlet var countryPicker: UIPickerView!
    @IBOutlet var getWeatherButton: UIButton!
    
    var countryCode: String = "UK"
    var countryKeys = [String]()
    var countryValues = [String]()
    var delegate: ChangeCityDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        configureCountryCodes()
        configureGestures()
        configureButtons()
    }
        
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    //MARK:- Button Actions
    ///Triggers city name change.
    @IBAction func getWeatherButtonTapped(sender: UIButton) {
        guard let cityName = changeCityTextfield.text, !cityName.isEmpty else {
            warningLabel.text = NSLocalizedString("lWarningLabel", comment: "")
            return
        }
        changeCityName(cityName)
    }
    
    ///Triggers navigation back to weather condtions.
    @IBAction func backButtonTapped(sender: UIButton) {
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    ///Changes the city name correcting for country and navigates back to weather conditions.
    private func changeCityName(_ cityName: String) {
        var newCityName = ""
        if !cityName.contains(",") {
            newCityName = cityName.trimmingCharacters(in: .whitespaces).appending(", \(countryCode)")
        }
        else {
            newCityName = cityName
        }
        delegate?.changeCityName(city: newCityName)
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Configure
    private func configureTextField() {
        changeCityTextfield.placeholder = NSLocalizedString("lEnterCityNameTextField", comment: "")
    }
    
    private func configureCountryCodes() {
        guard let url = Bundle.main.url(forResource: "countryCodes", withExtension: "json") else {fatalError()}
        guard let data = try? Data(contentsOf: url) else {fatalError()}
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []), let results = json as? [Any] else {fatalError()}
        for countryCode in results {
            guard let countryCode = countryCode as? [String: String] else {continue}
            countryKeys.append(countryCode["Code"]!)
            countryValues.append(countryCode["Name"]!)
        }
    }
    
    private func configureGestures() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func configureButtons() {
        getWeatherButton.setTitle(NSLocalizedString("lGetWeatherButton", comment: ""), for: .normal)
    }
    
}

//MARK:- UIPicker Extensions
extension ChangeCityViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryValues.count
    }
    
}

extension ChangeCityViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryCode = countryKeys[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel

        if let view = view {
            label = view as! UILabel
        }
        else {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 100))
        }
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                          NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 30.0)!]
        label.attributedText = NSAttributedString(string: countryValues[row], attributes: attributes)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.5
        label.sizeToFit()
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 80.0
    }
}

//MARK:- UITextView Extension
extension ChangeCityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let cityName = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        changeCityName(cityName)
        return true
    }
}
