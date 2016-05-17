//
//  MapConvenience.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-04-30.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import Foundation

extension MapClient {
    
    // MARK: Method to authenticate User credentials
    
    func authenticateUser(username: String, password: String, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        self.postToCreateSession(username, password: password) { (success, userID, error) in
            
            if success{
                self.userID = userID
                
                self.fetchAccountInfo(userID!, completionHandlerForFetch: completionHandlerForAuth)
            }
                
            else{
                completionHandlerForAuth(success: false, errorString: error?.localizedDescription)
            }
        }
    }
    
    
    
    // MARK: Method to fetch User Data
    
    func fetchAccountInfo(userID: String, completionHandlerForFetch: (success: Bool, errorString: String?) -> Void){
        
        getUserData() { (result, error) in
            
            guard let result = result else{
                print(error)
                completionHandlerForFetch(success: false, errorString: error?.localizedDescription)
                return
            }
            
            guard let firstName = result[Udacity.JSONResponseKeys.FirstName] as? String,
                let lastName = result[Udacity.JSONResponseKeys.LastName] as? String else {
                    
                    completionHandlerForFetch(success: false, errorString: "Cannot locate student record")
                    return
            }
            
            self.firstName = firstName
            self.lastName = lastName
            
            self.getStudentLocationByQuery(){ (result, error) in
                
                guard let result = result else{
                    print(error)
                    completionHandlerForFetch(success: false, errorString: "Error processing the request")
                    return
                }
                
                if !result.isEmpty{
                    self.userData = StudentInformation(dictionary: result[0])
                    print("Student Query : \(self.userData)")
                }
                
                completionHandlerForFetch(success: true, errorString: nil)
            }
            
        }
    }
    
    
    
    // MARK: GET Convenience Methods
    
    func getUserData(completionHandlerForUserData: (result: [String:AnyObject]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        
        var mutableMethod: String = Udacity.Methods.UserData
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: Udacity.URLKeys.UserID, value: String(self.userID!))!
        
        
        /* 2. Make the request */
        taskForGETMethod(ApiType.Udacity, method: mutableMethod, parameters: parameters) { (result, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            guard (error == nil) else {
                completionHandlerForUserData(result: nil, error: error)
                return
            }
            
            
            guard let result = result[Udacity.JSONResponseKeys.User] as? [String:AnyObject] else {
                
                completionHandlerForUserData(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                return
            }
            
            
            completionHandlerForUserData(result: result, error: nil)
        }
    }
    
    
    
    
    func getStudentLocations(completionHandlerForLocations: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [Parse.ParameterKeys.limit: Parse.ParameterValues.limitVal,
                          Parse.ParameterKeys.order: Parse.ParameterValues.orderVal]
        
        
        /* 2. Make the request */
        taskForGETMethod(ApiType.Parse, method: Parse.Methods.Location, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            guard (error == nil) else {
                completionHandlerForLocations(result: nil, error: error)
                return
            }
            
            guard let results = results[Parse.JSONResponseKeys.LocationResults] as? [[String:AnyObject]] else {
                
                completionHandlerForLocations(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                return
            }
            
            let locations = StudentInformation.locationsFromResults(results)
            completionHandlerForLocations(result: locations, error: nil)
        }
    }
    
    
    
    func getStudentLocationByQuery(completionHandlerForQueryLocation: (results: [[String:AnyObject]]?, error: NSError?) -> Void) {
        
        let queryParam = subtituteKeyInMethod(Parse.ParameterValues.queryVal, key: Parse.URLKeys.UserID, value: String(self.userID!))!
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [Parse.ParameterKeys.query: queryParam]
        
        /* 2. Make the request */
        taskForGETMethod(ApiType.Parse, method: Parse.Methods.Location, parameters: parameters) { (result, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            guard (error == nil) else {
                completionHandlerForQueryLocation(results: nil, error: error)
                return
            }
            
            
            guard let result = result[Parse.JSONResponseKeys.LocationResults] as? [[String:AnyObject]] else {
                
                completionHandlerForQueryLocation(results: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocation Query"]))
                return
            }
            
            completionHandlerForQueryLocation(results: result, error: nil)
        }
    }
    
    
    
    // MARK: POST Convenience Methods
    
    func postToCreateSession(username: String, password: String, completionHandlerForSession: (success: Bool, userID: String?, error: NSError?) -> Void)  {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        /* 2. Make the request */
        taskForPOSTMethod(ApiType.Udacity, method: Udacity.Methods.Session, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            
            guard (error == nil) else {
                // Check if error code is 2 i.e status code other than 2xx then show custom message or show error
                let errorString = (error!.code == 2) ? "Invalid email or password" : error!.localizedDescription
                completionHandlerForSession(success: false, userID: nil, error: NSError(domain: "postToCreateSession", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString]))
                return
            }
            
            guard let account = results[Udacity.JSONResponseKeys.Account] as? [String:AnyObject],
                let registered = account[Udacity.JSONResponseKeys.Registered] as? Bool,
                let userID = account[Udacity.JSONResponseKeys.Key] as? String else {
                    completionHandlerForSession(success: false, userID: nil, error: NSError(domain: "postToCreateSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToCreateSession"]))
                    return
            }
            
            if registered {
                completionHandlerForSession(success: true, userID: userID, error: nil)
            }
        }
    }
    
    
    
    func postToCreateSessionFacebook(token: String, completionHandlerForFBSession: (success: Bool, userID: String?, error: NSError?) -> Void)  {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        
        let jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(token)\"}}"
        
        /* 2. Make the request */
        taskForPOSTMethod(ApiType.Udacity, method: Udacity.Methods.Session, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            
            guard (error == nil) else {
                completionHandlerForFBSession(success: false, userID: nil, error: NSError(domain: "postToCreateSessionFacebook", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please make sure your Facebook is connected with Udacity account"]))
                return
            }
            
            guard let account = results[Udacity.JSONResponseKeys.Account] as? [String:AnyObject],
                let registered = account[Udacity.JSONResponseKeys.Registered] as? Bool,
                let userID = account[Udacity.JSONResponseKeys.Key] as? String else {
                    completionHandlerForFBSession(success: false, userID: nil, error: NSError(domain: "postToCreateSessionFacebook parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToCreateSessionFacebook"]))
                    return
            }
            
            if registered {
                completionHandlerForFBSession(success: true, userID: userID, error: nil)
            }
        }
    }
    
    
    
    func postStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandlerForPostLocation: (success: Bool, objectID: String?, error: NSError?) -> Void)  {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        
        let jsonBody = "{\"uniqueKey\": \"\(self.userID!)\", \"firstName\": \"\(self.firstName!)\", \"lastName\": \"\(self.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        /* 2. Make the request */
        taskForPOSTMethod(ApiType.Parse, method: Parse.Methods.Location, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            
            guard (error == nil) else {
                completionHandlerForPostLocation(success: false, objectID: nil, error: error)
                return
            }
            
            
            guard let objectID = results[Parse.JSONResponseKeys.ObjectID] as? String else {
                completionHandlerForPostLocation(success: false, objectID: nil, error: NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postStudentLocation"]))
                return
            }
            
            
            completionHandlerForPostLocation(success: true, objectID: objectID, error: nil)
        }
    }
    
    
    
    // MARK: PUT aka Update Convenience Methods
    
    func putStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandlerForPutLocation: (success: Bool, updatedStamp: String?, error: NSError?) -> Void)  {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        
        let jsonBody = "{\"uniqueKey\": \"\(self.userID!)\", \"firstName\": \"\(self.firstName!)\", \"lastName\": \"\(self.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        var mutableMethod: String = Parse.Methods.UpdateLocation
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: Parse.URLKeys.UserID, value: String(self.userData!.objectID))!
        
        /* 2. Make the request */
        taskForPUTMethod(ApiType.Parse, method: mutableMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            
            guard (error == nil) else {
                completionHandlerForPutLocation(success: false, updatedStamp: nil, error: error)
                return
            }
            
            guard let updatedStamp = results[Parse.JSONResponseKeys.UpdatedAt] as? String else {
                completionHandlerForPutLocation(success: false, updatedStamp: nil, error: NSError(domain: "putStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse putStudentLocation"]))
                return
            }
            
            
            completionHandlerForPutLocation(success: true, updatedStamp: updatedStamp, error: nil)
        }
    }
    
    
    
    // MARK: DELETE Convenience Methods
    
    func deleteSession(completionHandlerForUserData: (result: [String:AnyObject]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        
        /* 2. Make the request */
        taskForGETMethod(ApiType.Udacity, method: Udacity.Methods.Session, parameters: parameters) { (result, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            guard (error == nil) else {
                completionHandlerForUserData(result: nil, error: error)
                return
            }
            
            guard let result = result[Udacity.JSONResponseKeys.Session] as? [String:AnyObject] else {
                
                completionHandlerForUserData(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                return
            }
            
            
            completionHandlerForUserData(result: result, error: nil)
        }
    }
    
}