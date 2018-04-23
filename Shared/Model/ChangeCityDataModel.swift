//
//  ChangeCityDataModel.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import Foundation

class ChangeCityDataModel {
    
    var currentCountryCode = "GB"
    
    ///Country abbrivation and country name.
    lazy var countryCodes: (codes: [String], titles: [String]) = {return self.configureCountryCodes()}()
    lazy var countryTitlesDictonary: [String: String] = {
        var countryTitlesDictonary = [String: String]()
        for (index, key) in countryCodes.titles.enumerated() {
            countryTitlesDictonary[key] = countryCodes.codes[index]
        }
        return countryTitlesDictonary
    }()
    
    ///Loads the country codes from storage.
    func configureCountryCodes(_ bundle: Bundle = Bundle.main) -> ([String], [String]) {
        var countryCodes = ([String](), [String]())
        guard let url = bundle.url(forResource: "countryCodes", withExtension: "json") else {fatalError()}
        guard let data = try? Data(contentsOf: url) else {fatalError()}
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []), let results = json as? [Any] else {fatalError()}
        for countryCode in results {
            guard let countryCode = countryCode as? [String: String] else {continue}
            countryCodes.0.append(countryCode["Code"]!)
            countryCodes.1.append(countryCode["Name"]!)
        }
        return countryCodes
    }
}
