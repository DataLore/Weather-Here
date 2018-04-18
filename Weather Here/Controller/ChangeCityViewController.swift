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
    
    var delegate: ChangeCityDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK:- Button Actions
    ///Triggers city name change.
    @IBAction func getWeatherButtonTapped(sender: UIButton) {
        guard let cityName = changeCityTextfield.text, cityName != "" else {
            warningLabel.text = "Please enter a city name below"
            return
        }
        
        delegate?.changeCityName(city: cityName)
        self.dismiss(animated: true, completion: nil)
    }
    
    ///Triggers navigation back to weather condtions.
    @IBAction func backButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Configure
    private func configureLabels() {
        warningLabel.text = ""
    }
    
}
