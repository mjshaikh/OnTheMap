//
//  SecondViewController.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-02-16.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddLocationDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Computed property that returns array of Student location stored in model class MapClient
    
    var locations: [StudentInformation] {
        return Locations.sharedInstance.studentLocations!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        // Hides the activity indicator
        activityIndicator.stopAnimating()
        
        // If student locations array is empty then initiate download
        if Locations.sharedInstance.studentLocations == nil {
            downloadLocations()
        }
        else{ // Otherwise just update the tableView data
            tableView.reloadData()
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
        print("Downloading locations...")
        MapClient.sharedInstance.getStudentLocations(){ (locations, error) in
            
            performUIUpdatesOnMain {
                if let locations = locations { // If we have downloaded an array of locations
                    print("Total locations : \(locations.count)")
                    Locations.sharedInstance.studentLocations = locations
                    self.tableView.reloadData()
                    self.setUIEnabled(true)
                } else {  // There was an error
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
    
    
    // MARK: - UITableViewDataSource
    
    // Number of items in the table is the count of locations array
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    
    // Build each tableView row with name and url
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellView = tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath) as UITableViewCell!
        
        cellView.textLabel?.text = locations[indexPath.row].firstName + " " + locations[indexPath.row].lastName
        
        cellView.detailTextLabel!.text = locations[indexPath.row].mediaUrl
        
        return cellView
    }
    
    
    // MARK: - UITableViewDelegate
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        
        if let url = NSURL(string: locations[indexPath.row].mediaUrl){
            app.openURL(url)
        }
    }
    
    
    // MARK: - AddLocationDelegate
    
    // Implementing the delegate function to refresh location after a location is POSTED or UPDATED
    
    func refreshLocations() {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        downloadLocations()
    }
}

