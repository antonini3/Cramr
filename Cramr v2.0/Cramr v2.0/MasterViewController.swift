//
//  MasterViewController.swift
//  Cramr v2.0
//
//  Created by Anton Apostolatos on 1/26/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import UIKit
import CoreData

/**
    This class is the view controller for the master list on classes that the user is enrolled in.
    It is the first view that the user sees when he opens the app and is NOT currently enrolled in a session.
*/
class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var coursesIn: [String] = []
    
    var refreshingCourseList: Bool = false
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var sessionsForSelectedRow = [[String: String]]()
    
    /**
        This function is called after the user adds a new class from the CourseListTableView in order to display the new aded course.
        * Checks to see if there is network connection, if not, throws an error
    */
    @IBAction func popToPrevView(segue:UIStoryboardSegue) {
        if appDelegate.isConnectedToNetwork(){
            refreshCourseList()
            self.tableView.reloadData()
        } else {
            checkForNetwork(self, self.appDelegate, message: "Cannot add courses with no internet connection.")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /**
        This function is called after the database request is complete.
        * The courses that were returned from the query are set as the user courses
        * And the table is reloaded to show the new data
    */
    func refreshCourseListCallback(courses: [String], tableReload: Bool) {
        self.coursesIn = courses
        if tableReload {
            self.tableView.reloadData()
        }
        self.refreshingCourseList = false
        // the user is allowed to interact with the app again.
        self.view.userInteractionEnabled = true
    }

    /**
        After the user added a new course to his enrolled courses, the new course is displayed with this function.
        * The app delegate is called in order to get all the courses that the user is now enrolled in (incl new course)
        * With callback function that handles the tableView once the data is recieved.
    */
    func refreshCourseList(tableReload: Bool = true) {
        self.refreshingCourseList = true
        appDelegate.getCoursesFromAD(appDelegate.localData.getUserID(), tableReload: tableReload, cb: refreshCourseListCallback)
    }
    
    /**
        After the view is loaded, we stop the interacton and make sure that the network connection is alive.
        * If it is, then the course list is loaded, which is where the interaction is enabled again.
    */
    override func viewDidAppear(animated: Bool) {
        self.view.userInteractionEnabled = false
        if appDelegate.isConnectedToNetwork(){
            super.viewDidAppear(animated)
            designLayout()
            self.refreshCourseList()
        }
        
    }
    
    /**
        This function is called when the user wants to add new classes to his enrolled classes. It preforms the segue to the CourseListTableView.
        * Potential network errors are handled
    */
    func addButtonPressed(){
        if appDelegate.isConnectedToNetwork(){
            if appDelegate.isConnectedToNetwork(){
                self.performSegueWithIdentifier("toAddCourse", sender: nil)
            } else{
                checkForNetwork(self, self.appDelegate, message: "Cannot add courses with no internet connection.")
            }
        }
        checkForNetwork(self, self.appDelegate, message: "Cannot add courses with no internet connection.")
    }
    
    /**
        This function specifies the design layout for the entire page and for
    */
    func designLayout() {
        self.navigationController?.navigationBarHidden = false
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        self.title = "My Classes"
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false

        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = cramrBlue
        self.view.backgroundColor = .clearColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: 21.0)!]
        self.tableView.backgroundColor = UIColor.whiteColor()
        //        self.tableView.backgroundView = UIImageView(image: UIImage(named: "test_background"))
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.tableView?.tableFooterView = UIView()
    }
    
    /**
    This function specifies the design layout for the entire page and for
    */
    func updateCells() {
        checkForNetwork(self, self.appDelegate)
        self.refreshCourseList()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
       
    }
    
    func setupReload() {
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("updateCells"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        self.refreshControl!.tintColor = cramrBlue

    }
    
    /** 
        This function does the initial setup of the view.
        * It calls the function to load all the enrolled classes
        * It registers the CustomCourseTableCell class for the special cells we use to display the classes, which are larger and involve images.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshCourseList()
        appDelegate.registerPushNotifications(UIApplication.sharedApplication())
        self.tableView.registerClass(CustomCourseTableCell.self, forCellReuseIdentifier: "CourseCell")
        
        // Do any additional setup after loading the view, typically from a nib.
        designLayout()
        self.setupReload()
        checkForNetwork(self, self.appDelegate)
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addButtonPressed")
        
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coursesIn.count;
    }
    
    /**
        This function is executed after the database call is make to get the information about active sessions, in order to be displayed.
        * It shows the number of people and the number of sessions active
    
        :param:  numPeople  number of people in all sessions combined
        :param:  numSessions  number of currently active sessions
    */
    func cellUpdateCallback(numPeople: Int, numSessions: Int, cell: UITableViewCell) {
        (cell as! CustomCourseTableCell).updateCellContents(numPeople, numSessions: numSessions)
    }
    
    /**
        This function specifies the data in the cell, which includes the class name
        * It updates gets the current information about the class from the database
        * It utilizes a callback function after the database call to update the information
    
        :param:  tableView  the tableView that is being edited
        :param:  indexPath  the index of the current cell that is being created
    
        :returns: It returns the newly created cell
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CustomCourseTableCell = self.tableView.dequeueReusableCellWithIdentifier("CustomCourseCell") as! CustomCourseTableCell
        var fullCourseName = self.coursesIn[indexPath.row] as String
        cell.updateCellName(fullCourseName)
        (UIApplication.sharedApplication().delegate as! AppDelegate).updateCellAD(fullCourseName, cell: cell as UITableViewCell, cb: cellUpdateCallback)
        return cell
    }
    
    /**
        This function is called after the database call for the currently active sessions is complete. One of two things can    happen
        1) If there are active sessions, then the segue to SessionBrowserViewContoller is called, so that the user can swipe through the sessions.
        2) If there are no active sessions, the segue to the SessionCreationViewController is called
    
        *Network issues are handled

        :param:  sessions  this is a list of dictionaries, which stores the currently active sessions
    */
    func getSessionsCallback(sessions: [[String: String]]) {
        self.sessionsForSelectedRow = sessions
        if self.appDelegate.isConnectedToNetwork() {
            if sessions.count != 0 {
                self.performSegueWithIdentifier("showDetail", sender: nil)
            } else {
                self.performSegueWithIdentifier("createSession", sender: nil)
            }
        } else {
            self.view.userInteractionEnabled = true
        }
    }
    
    /**
        This functions handles if the user presses on a specific row and therefore selects a class
        * It calls the database to check what the currently active sessions for this class is
        * It has a callback function, which calls the write segue depending on if there are active sessions or not
        * Network issues are handled
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.appDelegate.isConnectedToNetwork() {
            self.view.userInteractionEnabled = false
            (UIApplication.sharedApplication().delegate as! AppDelegate).getSessionsAD(self.coursesIn[indexPath.row] as String, cb: getSessionsCallback)
        }
    }
    
    /**
        This callback functions is called after class is deleted out of the database list of enrolled classes
    */
    func deleteCourseCallback(indexPath: NSIndexPath) {
        //        refreshCourseList(tableReload: false)
        var index = find(self.coursesIn, self.coursesIn[indexPath.row] as String)
        self.coursesIn.removeAtIndex(index!)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    /**
        This function is called to remove a class from the currently enrolled classes of the user
        * It checks makes a database call to remove it from the database of enrolled classes for the current user
        * It has a callback function that show the changes on the tableview
    
        :param:  UITableView  the tableView to be eddited
        :param:  editingStyle  the editingStyle that, in this case, specifies the that a class is to be deleted
        :param:  indexPath  the row that should be deleted
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            (UIApplication.sharedApplication().delegate as! AppDelegate).deleteCourseFromUserAD((UIApplication.sharedApplication().delegate as! AppDelegate).localData.getUserID(), courseName: (self.coursesIn[indexPath.row] as String), index: indexPath, cb: deleteCourseCallback)
        }
    }

    /**
        This functions hangs up the user interaction and blocks the thread while the CourseList is refreshing. This makes sure that the user cannot press anything while the database calls are not yet complete and the data is not yet    completely shown.
        * Before it was possible to crash the application by switching classes too quickly. This is resolved this way.
        * May not be necessary if we don't see the concurrency issue any longer.
    */
    func waitForCompleteUpdate() {
        self.view.userInteractionEnabled = false
        while (self.refreshingCourseList) {
            sleep(10)
        }
        self.view.userInteractionEnabled = true
    }
    
    /** 
        This function specifies the two possible segues
        1) If there are active sessions, then the segue to SessionBrowserViewContoller is called, so that the user can swipe through the sessions.
        2) If there are no active sessions, the segue to the SessionCreationViewController is called
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            waitForCompleteUpdate()
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                var courseName = self.coursesIn[indexPath.row] as String
                var s = (segue.destinationViewController as! SessionBrowserViewController)
                s.courseName = courseName
                s.sessions = self.sessionsForSelectedRow
            }
        } else if segue.identifier == "createSession" {
            waitForCompleteUpdate()
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                var courseName = self.coursesIn[indexPath.row] as String
                (segue.destinationViewController as! SessionCreationViewController).courseName = courseName
                
            }
        }
        self.view.userInteractionEnabled = true
    }
}

