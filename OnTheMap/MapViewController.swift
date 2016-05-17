//
//  FirstViewController.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-02-16.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate, AddLocationDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Computed property that returns array of Student locations stored in model class Locations
    
    var locations: [StudentInformation]? {
        return Locations.sharedInstance.studentLocations
    }
    
    
    // We will create an array to store all point annotations
    // and then provided to the map view.
    var annotations = [MKPointAnnotation]()
    
    
    override func viewWillAppear(animated: Bool) {
        // Hides the activity indicator
        activityIndicator.stopAnimating()
        
        // If we don't have location annotations stored in array then initiate download
        if annotations.isEmpty {
            downloadLocations()
            print("Downloading locations...")
        }
    }
    
    
    @IBAction func logoutActionButton(sender: UIBarButtonItem) {
        
        // If we have the facebook access token then logout from FB
        if FBSDKAccessToken.currentAccessToken() != nil {
            
            print("Logging out from FB")
            
            let loginManager = FBSDKLoginManager()
            
            loginManager.logOut()
            
            FBSDKAccessToken.setCurrentAccessToken(nil)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else { // Otherwise call the convenience method to DELETE the session
            MapClient.sharedInstance.deleteSession(){ (results, error) in
                
                guard (error == nil) else{
                    print(error)
                    return
                }
                
                print(results)
                
                performUIUpdatesOnMain{
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func postLocationButton(sender: UIBarButtonItem) {
        
        // If the user don't have location data then we POST it as new location
        if MapClient.sharedInstance.userData == nil {
            
            showAddLocationViewController(editLocation: false)
        }
        else{ // Otherwise we throw a AlertDialog and UPDATE the location instead
            self.showAlertDialog("Overwrite", message: "You have already posted a Student location. Do you want to ovewrite?")
        }
    }
    
    
    @IBAction func refreshButton(sender: UIBarButtonItem) {
        // Download locations whenever refresh button is clicked
        downloadLocations()
    }
    
    
    /* This function displays AddLocationVC and depending upon editLocation flag it UPDATE or
     POST new location */
    
    func showAddLocationViewController(editLocation flag: Bool){
        
        let addLocationVC = self.storyboard?.instantiateViewControllerWithIdentifier("addLocationViewController") as! AddLocationViewController
        
        addLocationVC.editLocation = flag
        
        addLocationVC.addLocationDelegate = self
        
        addLocationVC.modalPresentationStyle = .FullScreen
        
        self.presentViewController(addLocationVC, animated: true, completion: nil)
    }
    
    
    /* This function downloads new locations and store them in model class Mapclient.
     It passes location data to addAnnotationToMap function */
    
    func downloadLocations(){
        
        setUIEnabled(false)
        
        MapClient.sharedInstance.getStudentLocations(){ (locations, error) in
            
            performUIUpdatesOnMain{
                
                if let locations = locations {      // If we have downloaded an array of locations
                    print("Total locations : \(locations.count)")
                    Locations.sharedInstance.studentLocations = locations
                    self.addAnnotationToMap(locations)
                    self.setUIEnabled(true)
                } else {    // There was an error
                    print(error)
                    let alert = UIAlertController(title: "Get Locations", message: error?.localizedDescription, preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: { (action:UIAlertAction) in
                    })
                    self.presentViewController(alert, animated: true, completion: nil)
                    alert.addAction(okAction)
                }
            }
        }
    }
    
    
    /* This function takes an array carrying location
     and adds the locations as an annotations on the Map */
    
    func addAnnotationToMap(locations: [StudentInformation]) {
        
        // If annotations already exist then remove them
        if !annotations.isEmpty {
            self.mapView.removeAnnotations(annotations)
            annotations.removeAll()
        }
        
        // For each location build the annotation
        
        for location in locations {
            
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName
            let last = location.lastName
            let mediaURL = location.mediaUrl
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
    }
    
    
    /* This function builds the alert dialog box to show Overwrite location message and shows
     AddLocationVC with edit flag as true if the user chooses to overwrite */
    
    func showAlertDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action:UIAlertAction) in
            self.showAddLocationViewController(editLocation: true)
        })
        let noAction = UIAlertAction(title: "No", style: .Default, handler: { (action:UIAlertAction) in
        })
        presentViewController(alert, animated: true, completion: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
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
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view".
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            
            if let url = NSURL(string: (view.annotation?.subtitle!)!){
                app.openURL(url)
            }
        }
    }
    
    
    // MARK: - AddLocationDelegate
    
    // Implementing the delegate function to refresh location after a location is POSTED or UPDATED
    
    func refreshLocations() {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        downloadLocations()
    }
    
    
}

