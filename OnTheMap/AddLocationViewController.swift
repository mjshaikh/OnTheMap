//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-05-02.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var stackLabels: UIStackView!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var linkTextField: UITextField!
    
    @IBOutlet weak var findOnTheMapButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Global variable
    var mapString: String? = nil
    var coordinate: CLLocationCoordinate2D? = nil
    
    // Flag to determine if we are in edit location mode
    var editLocation = false
    
    // AddLocationDelegate property to call function on the class that chooses to become deletgate
    var addLocationDelegate: AddLocationDelegate!
    
    
    override func viewWillAppear(animated: Bool) {
        
        // Intialize the UI
        toggleUIVisibilty(intialize: true)
    }
    
    
    /* This function toggles UI elements depending upon whether we are searching location or posting location */
    
    func toggleUIVisibilty(intialize flag : Bool){
        
        // Hides the activity indicator
        activityIndicator.stopAnimating()
        
        if flag {   // initialize necassary UI elements
            stackLabels.hidden = false
            locationTextField.hidden = false
            findOnTheMapButton.hidden = false
            
            mapView.hidden = true
            submitButton.hidden = true
            linkTextField.hidden = true
            
        }
        else{   // toggle necassary UI elements
            stackLabels.hidden = true
            locationTextField.hidden = true
            findOnTheMapButton.hidden = true
            
            mapView.hidden = false
            submitButton.hidden = false
            linkTextField.hidden = false
            
            cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            topView.backgroundColor = UIColor(red: 70.0/255, green: 130.0/255, blue: 180.0/255, alpha: 1.0)
            
            bottomView.backgroundColor = UIColor(red: 226, green: 226, blue: 226, alpha: 0.25)
        }
    }
    
    
    /* This function is called upon clicking find location button. It passes location string to geocode
     and authenticate valid address and throws error if invalid address is entered. */
    
    @IBAction func findLocationButton(sender: UIButton) {
        
        guard !locationTextField.text!.isEmpty else{
            showAlertDialog("", message: "Please enter a location")
            return
        }
        
        mapString = locationTextField.text!
        let geocoder = CLGeocoder()
        
        setUIEnabled(false)
        
        geocoder.geocodeAddressString(mapString!, completionHandler: {(placemarks, error) -> Void in
            
            // If valid address, move on else throw error dialog
            guard (error == nil) else{
                self.showAlertDialog("Invalid Address", message: "Could not geocode the address")
                self.setUIEnabled(true)
                return
            }
            
            self.setUIEnabled(true)
            
            // build annotation object and add it to the Map
            if let placemark = placemarks?.first {
                self.coordinate = placemark.location!.coordinate
                let annotation = MKPointAnnotation()
                annotation.coordinate = self.coordinate!
                self.mapView.addAnnotation(annotation)
                self.centerMapOnLocation(annotation.coordinate)
            }
            
            // Once valid address is annoted on map change UI to POST location interface
            
            self.toggleUIVisibilty(intialize: false)
        })
        
    }
    
    
    
    /* This function is called upon clicking submit location button. It calls network request
        to either POST or PUT location depending upon editLocation flag. */
    
    @IBAction func postLocationButton(sender: UIButton) {
        
        if !linkTextField.text!.isEmpty {
            
            // Validate URL and if location coordinate exists, move on or else throw error
            guard let url = validateURL(linkTextField.text!),
                let coordinate = coordinate else {
                    print("URL or Coordinate is nil")
                    return
            }
            
            
            if editLocation{    // If editing location call PUT method
                
                setUIEnabled(false)
                
                MapClient.sharedInstance.putStudentLocation(mapString!, mediaURL: url.absoluteString, latitude: coordinate.latitude, longitude: coordinate.longitude){ (success, updateStamp, error) in
                    
                    performUIUpdatesOnMain {
                        
                        if success{ // If sucessful call protocol function refreshLocation to update calling VC
                            print("Update Stamp:  \(updateStamp)")
                            
                            self.setUIEnabled(true)
                            
                            self.addLocationDelegate.refreshLocations()
                        }
                            
                        else{   // Throw error dialog
                            self.showAlertDialog("Edit Location", message: error!.localizedDescription)
                            self.setUIEnabled(true)
                        }
                    }
                }
            }
                
            else{   // If we are creating new location call POST method
                setUIEnabled(false)
                MapClient.sharedInstance.postStudentLocation(mapString!, mediaURL: url.absoluteString, latitude: coordinate.latitude, longitude: coordinate.longitude){ (success, objectID, error) in
                    
                    performUIUpdatesOnMain {
                        
                        if success{
                            
                            /* If sucessful, create a dict with all student info values and build StudentInformation struct
                               and store it in Model class MapClient for later access. */
                            
                            let studentInformation: [String:AnyObject] = [MapClient.Parse.JSONResponseKeys.UniqueKey : MapClient.sharedInstance.userID!,
                                MapClient.Parse.JSONResponseKeys.FirstName : MapClient.sharedInstance.firstName!,
                                MapClient.Parse.JSONResponseKeys.LastName : MapClient.sharedInstance.lastName!,
                                MapClient.Parse.JSONResponseKeys.MapString : self.mapString!,
                                MapClient.Parse.JSONResponseKeys.MediaURL : url.absoluteString,
                                MapClient.Parse.JSONResponseKeys.Latitude : coordinate.latitude,
                                MapClient.Parse.JSONResponseKeys.Longitude : coordinate.longitude,
                                MapClient.Parse.JSONResponseKeys.ObjectID : objectID!]
                            
                            
                            MapClient.sharedInstance.userData = StudentInformation(dictionary: studentInformation)
                            print("User Data \(MapClient.sharedInstance.userData.debugDescription)")
                            
                            self.setUIEnabled(true)
                            
                            // Call protocol function refreshLocation to update the calling VC
                            
                            self.addLocationDelegate.refreshLocations()
                        }
                            
                        else{   // throw error dialog if POSTing failed
                            self.showAlertDialog("Post Location", message: error!.localizedDescription)
                            self.setUIEnabled(true)
                        }
                        
                    }
                }
            }
        }
            
        else{   // throw error dialog if empty website URL
            showAlertDialog("", message: "Please enter a website URL")
        }
    }
    
    
    /* This method checks if a URL is valid by and makes necassry modification to it */
    
    func validateURL(urlString : String) -> NSURL? {
        
        let url = urlString.containsString("http://") ? NSURL(string: urlString) : NSURL(string: "http://" + urlString)
        
        guard UIApplication.sharedApplication().canOpenURL(url!) else{
            return nil
        }
        
        return url
    }
    
    
    /* This function toggles visiblity of view and indicator upon network request */
    
    private func setUIEnabled(enabled: Bool) {
        
        // adjust login button alpha
        if enabled {
            view.alpha = 1.0
            activityIndicator.stopAnimating()
        } else {
            view.alpha = 0.5
            activityIndicator.startAnimating()
        }
    }
    
    
    // MARK: - UITextFieldDelegate
    
    // Implementing the protocol function textFieldShouldReturn
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /* Called when cancel button is clicked on Post location page */
    
    @IBAction func cancelPostButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /* This function takes a CLLocationCoordinate2D and zoom in and centers on the map location */
    
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    /* This function takes a message String and shows alert dialog */
    
    func showAlertDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .Default, handler: { (action:UIAlertAction) in
        })
        presentViewController(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
}
