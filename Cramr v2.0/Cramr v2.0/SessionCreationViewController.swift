//
//  SessionCreationViewController.swift
//  Cramr v2.0
//
//  Created by Roberto Alvarez on 3/1/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import Foundation
import MapKit

/**
    View controller to create a new session. It allows the user to set the description of the session, and the location of the session. Both by typing it, and by setting the map.
*/
class SessionCreationViewController : UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    var courseName: String?  {
        didSet {
            self.title = getCourseID(self.courseName!)
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var pin: UIImageView!
    
    var newSession: [String: String]!
    
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var locationField: UITextField!
    
    /**
        This function is called when the user taps the create session button.
        * After some error checking, it calls the addSession function
    */
    @IBAction func createSession(sender: AnyObject) {
        var descriptionText = descriptionField.text
        var locationText = locationField.text
        
        //error checking, making sure that the user input a desciption and a location
        if descriptionText == "" && locationText == "" {
            errorAlert("Please fill in a description and a room!")
        } else if descriptionText == "" {
            errorAlert("Please fill in a description!")
        } else if locationText == "" {
            errorAlert("Please fill in a room!")
        } else if self.appDelegate.isConnectedToNetwork() {
            var center: CGPoint = mapView.center
            var loc: CLLocationCoordinate2D = mapView.camera.target
            addSession(locationText, description: descriptionText, geoTag: loc)
        } else {
            checkForNetwork(self, self.appDelegate)
        }
    }
    
    /**
        This function is a general alert function, it takes in one of three errors and outputs the message as an alert. The three possible errors are:
        * missing description and location,
        * missing description only,
        * missing location only.

        :param:  message  - a string that specifies the error message to output
    */
    func errorAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let closeAction = UIAlertAction(title: "Close", style: .Cancel) { action -> Void in
        }
        alert.addAction(closeAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
        Callback function, called after the new session has sucessfully been saved into the database.
        * It sets the current session for the user as the one he just specified and segues to the locked screen view.
    */
    func addSessionCallback(session: [String: String]) {
        self.newSession = session
        self.performSegueWithIdentifier("lockSessionView", sender: self)
    }
    
    /**
        This function calls the app delegate with the information from the new session. It is called when the user wants to create the new session.
        * In the app delegate function, the database is updated with the new session and then the callback function sets the current session.
    
        :param:  location  the user specified location
        :param:  description  the user specified description
        :param:  geoTag  the map specified location as a coordinate
    */
    func addSession(location: String, description: String, geoTag: CLLocationCoordinate2D) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).addSessionAD((UIApplication.sharedApplication().delegate as! AppDelegate).localData.getUserID(), courseName: self.courseName!, description: description, location: location, geoTag: geoTag, cb: addSessionCallback)
    }
    
    /**
        This function executes the segue to the locked session view and passes the newSession as an object
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "lockSessionView" {
            var destController = segue.destinationViewController as! SessionLockedViewController
            destController.session = self.newSession
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = false
            addMapButton(self.view, self)
        }
    }
    
    /**
        This function updates the location on the map as the user moves around on the map
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            mapView.camera = GMSCameraPosition(target : location.coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
  
    /**
        This function zooms back to the current location of the user, if he clicks the button to recenter on the map
    */
    @IBAction func tappedLocationButton(sender: AnyObject) {
        if (self.mapView.myLocation != nil) {
            self.mapView.animateToCameraPosition(GMSCameraPosition(target: self.mapView.myLocation.coordinate, zoom: 18, bearing: 0, viewingAngle: 0))
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    /**
        This function sets up the map. Specifies the location of the marker with some math that took as longer to figure out than we would like to admit
    */
    func setupMap() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        self.mapView.padding = UIEdgeInsets(top: 100, left: 0, bottom: 70, right: 0)
        
        var centered: CGPoint = mapView.center
        var markerCenter = ((self.mapView.frame.height - 70) - (self.locationLabel.frame.origin.y + self.locationLabel.frame.height))/2.0
        markerCenter -= self.pin.frame.height / 2.0
        markerCenter += 64 //height of status plus nav bar, i think
        centered.y = markerCenter
        pin.center = centered
    }
    

    /**
        This function specifies the navigation items, the colors of the view and what is loaded immidately.
    */
    override func viewDidLoad() {
        descriptionField.delegate = self
        locationField.delegate = self
        
        // It breaks here
        self.view.backgroundColor = UIColor.whiteColor()
        //NSLog("couseName: " + self.courseName!)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        setupMap()
        
        addBlur(self.view, [self.descriptionLabel, self.locationLabel])
        self.view.bringSubviewToFront(self.descriptionField)
        self.view.bringSubviewToFront(self.locationField)
  
    }
    
}