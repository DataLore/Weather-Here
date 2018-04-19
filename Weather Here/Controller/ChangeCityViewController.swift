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
    @IBOutlet var getWeatherButton: UIButton!
    
    var delegate: ChangeCityDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        configureGestures()
        configureButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    private func changeCityName(_ cityName: String) {
        delegate?.changeCityName(city: cityName)
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Configure
    private func configureTextField() {
        changeCityTextfield.placeholder = NSLocalizedString("lEnterCityNameTextField", comment: "")
        changeCityTextfield.delegate = self
    }
    
    private func configureGestures() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func configureButtons() {
        getWeatherButton.setTitle(NSLocalizedString("lGetWeatherButton", comment: ""), for: .normal)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - UITextView Extension
extension ChangeCityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let cityName = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        changeCityName(cityName)
        return true
    }
}
