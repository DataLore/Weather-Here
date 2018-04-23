//
//  ProjectDataModel.swift
//  Weather Here
//
//  Copyright © 2018 Emerald River. All rights reserved.
//

import Foundation

class ProjectDataModel {
 
    let apiKey: String
    
    init(bundle: Bundle = Bundle.main) {
        guard let plist = bundle.url(forResource: "Keys", withExtension: "plist") else {fatalError()}
        guard let storedKey = NSDictionary(contentsOf: plist) as? [String: Any] else {fatalError()}
        guard let apiKey = storedKey["APIKey"] as? String else {fatalError()}
        self.apiKey = apiKey
    }
}

