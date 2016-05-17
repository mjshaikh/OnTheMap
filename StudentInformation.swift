//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-02-22.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    let firstName: String
    let lastName: String
    let uniqueKey: String
    let mapString: String
    let latitude: Double
    let longitude: Double
    let mediaUrl: String
    let objectID: String
    
    // MARK: Initializers
    
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary[MapClient.Parse.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[MapClient.Parse.JSONResponseKeys.LastName] as! String
        uniqueKey = dictionary[MapClient.Parse.JSONResponseKeys.UniqueKey] as! String
        mapString = dictionary[MapClient.Parse.JSONResponseKeys.MapString] as! String
        latitude = dictionary[MapClient.Parse.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[MapClient.Parse.JSONResponseKeys.Longitude] as! Double
        mediaUrl = dictionary[MapClient.Parse.JSONResponseKeys.MediaURL] as! String
        objectID = dictionary[MapClient.Parse.JSONResponseKeys.ObjectID] as! String
    }
    
    
    static func locationsFromResults(results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var locations = [StudentInformation]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            locations.append(StudentInformation(dictionary: result))
        }
        
        return locations
    }
    
}