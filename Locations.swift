//
//  Locations.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-05-17.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import Foundation

class Locations: NSObject {
    
    // Array to store locations of all the students
    var studentLocations: [StudentInformation]? = nil
    
    // MARK: One line Singleton shared instance
    
    static let sharedInstance = Locations()
    
    
    private override init() {
        super.init()
    }
}