//
//  SessionBrowserViewController.swift
//  Cramr v2.0
//
//  Created by Anton Apostolatos on 2/4/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import Foundation
import UIKit


/**
    This class creates the container that allows the user to view and swipe between the different sessions that are active. It controls the browser view.
*/
class SessionBrowserViewController : UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var browserMapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    
    var sessions: [[String: String]]?
    
    var courseName: String? {
        didSet {
        }
    }
    
    //If there are no active sessions, then the user is automatically directed to the createSessionView
    func newSesh() {
        self.performSegueWithIdentifier("createSessionView", sender: self)
    }
    
    /**
        This function sets up the view and the naviation bar and all the colours
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        //addMapButton(self.view, self)
        
        //If there are no active sessions, then the user is automatically directed to the createSessionView
        if sessions?.count == 0 {
            self.newSesh()
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = getCourseID(self.courseName!)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "newSesh")
        
        setupMap()
    }
    
    //UNUSED
    @IBAction func tappedLocationButton(sender: AnyObject) {
        if (self.browserMapView.myLocation != nil) {
            self.browserMapView.animateToCameraPosition(GMSCameraPosition(target: self.browserMapView.myLocation.coordinate, zoom: 18, bearing: 0, viewingAngle: 0))
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            browserMapView.myLocationEnabled = true
            browserMapView.settings.myLocationButton = false
            //addMapButton(self.view, self) // UPDATE PRAMETERS TO INCLUDE LOCATION
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            self.browserMapView.camera = GMSCameraPosition(target : location.coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
    
    /**
    This functions sets up the map that shows the location.
    * It gets the lat and long positions of the study group and sets the camera there
    * It also displays the user
    */
    func setupMap() {
        
        self.browserMapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        self.browserMapView.myLocationEnabled = true
        
//        if (self.browserMapView.myLocation != nil) {
//        var latitude = self.browserMapView.myLocation.coordinate.latitude
//        var longitude = self.browserMapView.myLocation.coordinate.longitude
//        self.browserMapView.padding = UIEdgeInsets(top: 150, left: 0, bottom: 70, right: 0)
//        var camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 17.0)
//        self.browserMapView.camera = camera
//        }
        
        //Adding Session Markers
        for var i = 0; i < self.sessions!.count; i++ {
            var session = self.sessions![i] as [String : String]
            var latitude: Double = (session["latitude"]! as NSString).doubleValue
            var longitude: Double = (session["longitude"]! as NSString).doubleValue
            var position = CLLocationCoordinate2DMake(latitude, longitude)
            var marker = CustomBrowserMarker(position: position)
            markers.append(marker)
            marker.session = session
            marker.index = i
            //var marker = GMSMarker(position: position)
            marker.icon = UIImage(named: "blue_map_marker")
            marker.map = self.browserMapView
        }
        
        
        
        
        //        self.sessionMapView.layer.borderWidth = 1.0
        //        self.sessionMapView.layer.borderColor = cramrBlue.CGColor
    }
    
    
    func updateMapMarker(index: Int) {
        if (prevMarker != -1) {
            markers[prevMarker].icon = UIImage(named: "blue_map_marker")
        }
        markers[index].icon = UIImage(named: "grey_marker")
        prevMarker = index
    }
    
    var markers = [CustomBrowserMarker]()
    var prevMarker : Int = -1
    
    func mapView (mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        if (prevMarker != -1) {
            markers[prevMarker].icon = UIImage(named: "blue_map_marker")
        }
        
        
        
        var mark = marker as! CustomBrowserMarker
        var sessionID = mark.session["sessionID"]
        var index = mark.index
        markers[index].icon = UIImage(named: "grey_marker")
        
        prevMarker = index
        
        (sessionViewController as! SessionViewController).goToView(index)

        
        return false
    }
    
    var sessionViewController =  UIViewController()
    
    
    /**
        This function controls the two possible segues:
        * If there are no active sessions, then the user is automatically directed to the createSessionView
        * If there are active sessions, then the user is segued to the SessionViewController, which is the container that houses the different active sessions
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sessionSwiper" {
            
            sessionViewController = segue.destinationViewController as! UIViewController
            (segue.destinationViewController as! SessionViewController).sessions = self.sessions!
        } else if segue.identifier == "createSessionView" {
            (segue.destinationViewController as! SessionCreationViewController).courseName = self.courseName
        }
    }
    
}