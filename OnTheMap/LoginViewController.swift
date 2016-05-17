//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-04-28.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign this class as delegate to fbLoginButton and set permissions
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile"]
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // If we don't have FB access token then make fbLoginButton button visible
        if FBSDKAccessToken.currentAccessToken() == nil {
            fbLoginButton.hidden = false
            activityIndicator.stopAnimating()
        }
        else {
            activityIndicator.startAnimating()
        }
    }
    
    /* This function is called when our native loginButton is clicked */
    @IBAction func loginButton(sender: UIButton) {
        
        // If username and password textfield are empty throw error dialog
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            showAlertDialog("Login Failed", message: "Username or Password Empty.", updateUI: false)
        } else { // Else disable UI and authenticate user
            setUIEnabled(false)
            
            MapClient.sharedInstance.authenticateUser(usernameTextField.text!, password: passwordTextField.text!) { (success, errorString) in
                
                performUIUpdatesOnMain {
                    if success { // If sucessful then complete login
                        self.completeLogin()
                    } else {    // Else throw an error dialog
                        self.showAlertDialog("Login Failed", message: errorString!, updateUI: true)
                    }
                }
            }
        }
        
    }
    
    
    /* This function is called login is sucessful to show our TabBarController */
    
    private func completeLogin() {
        self.setUIEnabled(true)
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    /* Alert dialog to show any error during login process. It takes a Bool updateUI
        to revert disabled UI elements */
    
    func showAlertDialog(title: String, message: String, updateUI: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction) in
            if updateUI {   // If the flag is set then enable UI elements
                self.setUIEnabled(true)
            }
        })
        presentViewController(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    
    // MARK: - FBSDKLoginButtonDelegate
    
    // Implementing the protocol function of login button of Facebook SDK

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        // If no error move on else print error
        guard (error == nil) else {
            print(error)
            return
        }
        
        // Update UI while processing network request
        
        setUIEnabled(false)
        
        if result.token != nil {    // If we have a FB access token then continue POST create session method
            
            let access_token = FBSDKAccessToken.currentAccessToken().tokenString
            
            MapClient.sharedInstance.postToCreateSessionFacebook(access_token)
            { (success, userID, error) in
                
                // If sucessful, store the userID and fetch user account info
                
                if success {
                    MapClient.sharedInstance.userID = userID
                    
                    MapClient.sharedInstance.fetchAccountInfo(userID!){ (success, errorString) in
                        
                        performUIUpdatesOnMain {
                            if success {
                                self.completeLogin()
                            }
                            else {
                                self.showAlertDialog("Login Failed", message: error!.localizedDescription, updateUI: true)
                            }
                        }
                    }
                }
                else {
                    self.showAlertDialog("Login Failed", message: error!.localizedDescription, updateUI: true)
                }
            }
        }
    }
    
    
    // Implementing the protocol function loginButtonDidLogOut of Facebook SDK
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Logged out")
    }
    

    // MARK: - UITextFieldDelegate
    
    // Implementing the protocol function textFieldShouldReturn
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /* This functino toggles visibility of necassary UI elements on login page */
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        // adjust login button alpha
        if enabled {
            view.alpha = 1.0
            activityIndicator.stopAnimating()
        } else {
            view.alpha = 0.5
            activityIndicator.startAnimating()
        }
    }
    
}
