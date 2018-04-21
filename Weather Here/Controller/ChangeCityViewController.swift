//
//  ChangeCityViewController.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import UIKit

protocol ChangeCityControllerDelegate {
    func getCountryKeys() -> [String]
    func getCountryValues() -> [String]
    func changeCityName(city: String)
}

class ChangeCityViewController: UIViewController {
    
    @IBOutlet weak var changeCityTextfield: UITextField!
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var getWeatherButton: UIButton!
    
    var delegate: ChangeCityControllerDelegate!
    ///Current ISO country code.
    var countryCode: String = "GB"
    ///ISO country codes.
    var countryKeys: [String]!
    ///Associated full names for ISO country codes.
    var countryValues: [String]!
    
    convenience init(_ delegate: ChangeCityControllerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCountryCodes()
        configureTextField()
        confgiureCountryPicker()
        configureGestures()
        configureButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTextField()
    }
        
    @objc private func dismissKeyboard() {view.endEditing(true)}

    //MARK:- Button Actions
    ///Triggers city name change.
    @IBAction func getWeatherButtonTapped(sender: UIButton) {
        guard let cityName = changeCityTextfield.text, !cityName.isEmpty else {
            let attributes = [NSAttributedStringKey.foregroundColor: UIColor.red,
                              NSAttributedStringKey.font: changeCityTextfield.font!]
            changeCityTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("lWarningLabel", comment: ""), attributes: attributes)
            return
        }
        changeCityName(cityName)
    }
    
    ///Triggers navigation back to weather condtions.
    @IBAction func backButtonTapped(sender: UIButton) {
        dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }
    
    ///Changes the city name correcting for country and navigates back to weather conditions.
    private func changeCityName(_ cityName: String) {
        let city = cityName.trimmingCharacters(in: .whitespaces).appending(", \(countryCode)")
        delegate.changeCityName(city: city)
        dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Configure
    private func configureTextField() {
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                          NSAttributedStringKey.font: changeCityTextfield.font!]
        changeCityTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("lEnterCityNameTextField", comment: ""), attributes: attributes)
        changeCityTextfield.text = ""
    }
    
    private func configureCountryCodes() {
        countryKeys = delegate.getCountryKeys()
        countryValues = delegate.getCountryValues()
    }
    
    private func confgiureCountryPicker(_ locale: Locale = Locale.current) {
        guard let region = locale.regionCode else {return}
        for i in 0..<countryKeys.count {
            if countryKeys[i] == region {
                countryCode = region
                countryPicker.selectRow(i, inComponent: 0, animated: false)
                return
            }
        }
    }
    
    private func configureGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func configureButtons() {
        getWeatherButton.setTitle(NSLocalizedString("lGetWeatherButton", comment: ""), for: .normal)
    }
}

//MARK:- UIPicker Extension
extension ChangeCityViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {return 1}
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {return countryValues.count}
}

extension ChangeCityViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {return 80.0}
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {countryCode = countryKeys[row]}
    
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
}

//MARK:- UITextView Extension
extension ChangeCityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let cityName = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        changeCityName(cityName)
        return true
    }
}
