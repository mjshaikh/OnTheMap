//
//  MapClient.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-03-02.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import Foundation

class MapClient: NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // Students unique key
    var userID: String? = nil
    
    var firstName: String? = nil
    
    var lastName: String? = nil
    
    // Struct to store student information
    var userData : StudentInformation? = nil
    
    // Array to store locations of all the students
    var studentLocations: [StudentInformation]? = nil
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    
    
    // MARK: GET
    
    func taskForGETMethod(apiName: ApiType, method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        print(mapUrlFromParameters(apiName, parameters: parameters, withPathExtension: method))
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: mapUrlFromParameters(apiName, parameters: parameters, withPathExtension: method))
        
        // If API is Parse we add Parse specific details to request
        if apiName == ApiType.Parse {
            request.addValue(Parse.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Parse.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5. Skip the first 5 characters of the response If the API is Udacity */
            
            let newData = (apiName == ApiType.Udacity) ? data.subdataWithRange(NSMakeRange(5, data.length - 5)) : data
            
            /* 6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    
    func taskForPOSTMethod(apiName: ApiType, method: String, var parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        print(mapUrlFromParameters(apiName, parameters: parameters, withPathExtension: method))
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: mapUrlFromParameters(apiName, parameters: parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        
        // If API is Parse we add Parse specific details to request
        if apiName == ApiType.Parse {
            request.addValue(Parse.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Parse.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        else{   // Otherwise add Udacity specific details to request
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String, code: Int) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: code, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)", code: 1)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!", code: 2)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!", code: 3)
                return
            }
            
            /* 5 Skip the first 5 characters of the response If the API is Udacity */
            
            let newData = (apiName == ApiType.Udacity) ? data.subdataWithRange(NSMakeRange(5, data.length - 5)) : data
            
            /* 6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    
    func taskForDELETEMethod(apiName: ApiType, method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        print(mapUrlFromParameters(apiName, parameters: parameters, withPathExtension: method))
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: mapUrlFromParameters(apiName, parameters: parameters, withPathExtension: method))
        
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5. Skip the first 5 characters of the response If the API is Udacity */
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            /* 6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    func taskForPUTMethod(apiName: ApiType, method: String, var parameters: [String:AnyObject], jsonBody: String, completionHandlerForPUT: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        print(mapUrlFromParameters(apiName, parameters: parameters, withPathExtension: method))
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: mapUrlFromParameters(apiName, parameters: parameters, withPathExtension: method))
        request.HTTPMethod = "PUT"
        request.addValue(Parse.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Parse.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPUT(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPUT)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    
    // substitute the key for the value that is contained within the method name
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // create a URL from parameters
    private func mapUrlFromParameters(apiName: ApiType, parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        
        // If API is Udacity we add Udacity specific details to NSURLComponents
        if apiName == ApiType.Udacity {
            components.scheme = MapClient.Udacity.ApiScheme
            components.host = MapClient.Udacity.ApiHost
            components.path = MapClient.Udacity.ApiPath + (withPathExtension ?? "")
        }
        else { // Otherwise we add Parse specific details
            components.scheme = MapClient.Parse.ApiScheme
            components.host = MapClient.Parse.ApiHost
            components.path = MapClient.Parse.ApiPath + (withPathExtension ?? "")
        }
        
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> MapClient {
        struct Singleton {
            static var sharedInstance = MapClient()
        }
        return Singleton.sharedInstance
    }
    
}

