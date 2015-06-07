//
//  SessionContentViewController.swift
//  Cramr v2.0
//
//  Created by Anton Apostolatos on 2/4/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import Foundation

/**
    This class regulates the information that is shown about each session, when the user browses through the currently active session.
*/
class SessionContentViewController: UIViewController {
    
    var session: [String: String]!
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var descript: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
//    
//    @IBOutlet weak var sessionMapView: GMSMapView!
    
    @IBOutlet weak var currentMembersScrollView: UIScrollView!
    
    var currentMembersDict = [String : String]()
    
    /**
        This functions specifies the callback after the user joins a new session
        * It segues the locked screen session of that session
    */
    func joinSessionCallback() {
        self.performSegueWithIdentifier("pushToLockedFromJoin", sender: self)
    }
    
    /**
        This function is called when the user joins a current session.
        * It calls the database to add the session to the user information and add the user to the session information
        * It has a callback function that regulates the segue
    */
    @IBAction func joinButton(sender: AnyObject) {
        if self.appDelegate.isConnectedToNetwork() {
            (UIApplication.sharedApplication().delegate as! AppDelegate).joinSessionAD(session["sessionID"]!, userID: (UIApplication.sharedApplication().delegate as! AppDelegate).localData.getUserID(), cb: joinSessionCallback)
        } else {
            checkForNetwork(self, self.appDelegate)
        }
    }
    
    /**
        This is the callback function after the users are called for the session that is currently viewed
        * It saves the users in the session to a list
        * It then calls the database with the list of userIDs in order to get the user pictures that are saved seperately in the database
        * It has a callback function in order to display the pictures
        
        :param:  userNamesAndIds a list of tuples (username, userID)
    */
    func setUsersLabelCallback(userNamesAndIds: [(String, String)]) {
        var userIDs = [String]()
        for elem in userNamesAndIds {
            userIDs.append(elem.1)
            self.currentMembersDict[elem.1] = elem.0
        }
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).getSessionUsersPicturesAD(userIDs, cb: displayCurrentUsers)
        
    }
    /**
        This function sets the labels about every session
        * It specifies the description and the location of the sessions in their field. This information was taken already when the user clicked on the class the to view the sessions
        * It calls the database to get the users of this session
        * It has a callback function that specifies what user information should be displayed
    */
    func setLabels() {
        descript.text = "  We're working on: " + (session["description"]! as String)
        locationLabel.text = "  We're working at: " + (session["location"]! as String)
        descript.numberOfLines = 0
        (UIApplication.sharedApplication().delegate as! AppDelegate).getSessionUsersAD(session["sessionID"]!, cb: setUsersLabelCallback)
        
    }
    /**
        This function displays the pictures and the names of the users in each session
        * First it places the images
        * Then it places the strings

        :param:  pictDict  a dictionary of user names to their pictures
    */
    func displayCurrentUsers(pictDict : [String: UIImage]) {
        self.currentMembersScrollView.backgroundColor = UIColor.clearColor()
        
        self.currentMembersScrollView.canCancelContentTouches = false
        self.currentMembersScrollView.indicatorStyle = UIScrollViewIndicatorStyle.White
        self.currentMembersScrollView.clipsToBounds = true
        self.currentMembersScrollView.scrollEnabled = true
        
        
        var cx = CGFloat(5)
        var cy = CGFloat(25)
        
        for im in pictDict.values {
            var imView = UIImageView(image: im)
            
            var rect = imView.frame
            rect.size.height = 50.0
            rect.size.width = 50.0
            rect.origin.x = cx
            rect.origin.y = cy
            
            imView.frame = rect
            imView.layer.cornerRadius = imView.frame.size.width / 2
            imView.clipsToBounds = true
            
            imView.layer.borderWidth = 1.0
            imView.layer.borderColor = cramrBlue.CGColor
            
            self.currentMembersScrollView.addSubview(imView)
            
            cx += imView.frame.size.width + 10
        }
        
        var lx = CGFloat(5)
        var ly = CGFloat(0)
        
        for user in pictDict.keys {
            var label = UILabel()
            label.text = getShortName(currentMembersDict[user]!)
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont(name: label.font.fontName, size: 10)
            label.textColor = cramrBlue
            var labelRect = CGRect()
            labelRect.size.height = 25.0
            labelRect.size.width = 50.0
            labelRect.origin.x = lx
            labelRect.origin.y = ly
            
            label.frame = labelRect
            self.currentMembersScrollView.addSubview(label)
            
            lx += label.frame.size.width + 10
        }
        
        self.currentMembersScrollView.contentSize = CGSizeMake(cx, self.currentMembersScrollView.bounds.size.height)
        
    }
    
    /**
        This functions sets up the map that shows the location.
        * It gets the lat and long positions of the study group and sets the camera there
        * It also displays the user
    */
//    func setupMap() {
//        var latitude: Double = (self.session["latitude"]! as NSString).doubleValue
//        var longitude: Double = (self.session["longitude"]! as NSString).doubleValue
//        self.sessionMapView.padding = UIEdgeInsets(top: 150, left: 0, bottom: 70, right: 0)
//
//        var camera = GMSCameraPosition.cameraWithLatitude(latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees, zoom: 17.0)
//        self.sessionMapView.camera = camera
//        self.sessionMapView.myLocationEnabled = true
//        
//        var position = CLLocationCoordinate2DMake(latitude, longitude)
//        var marker = GMSMarker(position: position)
//        marker.icon = UIImage(named: "blue_map_marker")
//        marker.map = self.sessionMapView
//        
////        self.sessionMapView.layer.borderWidth = 1.0
////        self.sessionMapView.layer.borderColor = cramrBlue.CGColor
//    }
    
    
    /**
        This function sets up the entire page included the map and the labels.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
//        setupMap()
        self.setLabels()
        //addBlur(self.view, [self.descript, self.locationLabel, self.currentMembersScrollView])
        
    }
    
    func convertViewToImage() -> UIImage {
        //var view = UIView()
    
        //view.bounds = self.view.bounds
        //view.addSubview(self.view)
        //addBlur(view, [view])
        var image = view.getImage()
//        var rect = CGRectMake(2, 2, image.size.width - 4, image.size.height - 4)
//        
//        var imageRef = CGImageCreateWithImageInRect(image.CGImage, rect)
//        
//        
//        var croppedImage = UIImage(CGImage: imageRef)
        return image
    }
    
    
    /**
        This function preforms the segue to the locked screen if the user decides to join a session
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushToLockedFromJoin" {
            (segue.destinationViewController as! SessionLockedViewController).session = self.session
        } else if segue.identifier == "chatSegue" {
            (segue.destinationViewController as! MessagesViewController).backgroundImage = convertViewToImage()
            (segue.destinationViewController as! MessagesViewController).session = self.session
        }
    }
    
    @IBAction func popBackToSessionContent(segue:UIStoryboardSegue) {
        
    }
}