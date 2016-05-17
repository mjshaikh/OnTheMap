//
//  Constants.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-02-23.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import Foundation


extension MapClient {
    
    enum ApiType { case Udacity, Parse }
    
    // MARK: Udacity Constants
    struct Udacity {
        
        //MARK: Facebook Application ID
        static let FacebookAppID : String = "365362206864879"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        
        
        struct Methods {
            
            // MARK: Student Location
            static let Session = "/session"
            static let UserData = "/users/{id}"
        }
        
        // MARK: URL Keys
        struct URLKeys {
            static let UserID = "id"
        }
        
        
        // MARK: Response Keys
        struct JSONResponseKeys {
            
            static let Account = "account"
            static let Session = "session"
            static let Registered = "registered"
            static let Key = "key"
            static let User = "user"
            static let FirstName = "first_name"
            static let LastName = "last_name"
        }
    }
    
    
    
    // MARK: Parse Constants
    struct Parse {
        
        
        //MARK: Application ID
        static let AppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: API Key
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes"
        
        
        struct Methods {
            
            // MARK: Student Location
            static let Location = "/StudentLocation"
            static let UpdateLocation = "/StudentLocation/{id}"
        }
        
        // MARK: URL Keys
        struct URLKeys {
            static let UserID = "id"
        }
        
        // MARK: Parameter Keys
        struct ParameterKeys {
            static let limit = "limit"
            static let skip = "skip"
            static let order = "order"
            static let query = "where"
        }
        
        // MARK: Parameter Values
        struct ParameterValues {
            static let limitVal = "100"
            static let orderVal = "-updatedAt"
            static let queryVal = "{\"uniqueKey\":\"{id}\"}"
        }
        
        // MARK: Response Keys
        struct JSONResponseKeys {
            
            static let FirstName = "firstName"
            static let LastName = "lastName"
            static let UniqueKey = "uniqueKey"
            static let MapString = "mapString"
            static let Latitude = "latitude"
            static let Longitude = "longitude"
            static let ObjectID = "objectId"
            static let MediaURL = "mediaURL"
            static let LocationResults = "results"
            static let UpdatedAt = "updatedAt"
        }
    }
    
}