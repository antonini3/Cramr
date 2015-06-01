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
class SessionBrowserViewController : UIViewController {
    
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
    }
    
    /**
        This function controls the two possible segues:
        * If there are no active sessions, then the user is automatically directed to the createSessionView
        * If there are active sessions, then the user is segued to the SessionViewController, which is the container that houses the different active sessions
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sessionSwiper" {
            (segue.destinationViewController as! SessionViewController).sessions = self.sessions!
        } else if segue.identifier == "createSessionView" {
            (segue.destinationViewController as! SessionCreationViewController).courseName = self.courseName
        }
    }
    
}