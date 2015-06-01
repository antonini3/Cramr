//
//  AppDelegate.swift
//  Cramr v2.0
//
//  Created by Anton Apostolatos on 1/26/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import UIKit
import CoreData
import SystemConfiguration

@UIApplicationMain
/**
    This class handles all app delegation. This includes storing instances of the LocalDatastore and
    DatabaseAccess classes for use by all view controllers.
*/
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var DBAccess: DatabaseAccess?
    
    var session = [String: String]()
    
    var localData = LocalDatastore()
    
    
    /**
        This functions sets up Parse
    */
    func setupParse() {
        Parse.enableLocalDatastore()
        Parse.setApplicationId("sXNki6noKC9lOuG9b7HK0pAoruewMqICh8mgDUtw", clientKey: "Gh80MLplqjiOUFdmOP2TonDTcdmgevXbGaEhpGZR")
    }
    
    func setupDBAccess() {
        self.DBAccess = DatabaseAccess()
    }
    
    /**
        This function gets the courses the user is in to display on the course TableView
        * It has a callback that sends the courses that the user is enrolled in and information whether the courselist should be reloaded or not
        
        :param:  userID  the userID of the current user
        :param:  tableReload  a boolean specifiying whether or not the table should be reloaded after the update
    */
    func getCoursesFromAD(userID: String, tableReload: Bool, cb: ([String], Bool) -> ()) {
        self.DBAccess!.getCourses(userID, tableReload: tableReload, callback: cb)
    }
    
    /**
        This function gets all the courses, as the user is typing, and displays them for him to enroll in a new course
        * the callback function displays the list of the courses that are to be displayed
        
        :param:  searchText  the text of the users query
    */
    func getCourseListFromAD(searchText: String, cb: ([String]) -> ()) {
        self.DBAccess!.getCourseList(searchText, callback: cb)
    }
    
    /**
        This function is called when the user adds a new class to his current classes
        
        :param:  userID  the userID of the current user
        :param:  courseName  the name of the course that the user is adding
    */
    func addCourseToUserAD(userID: String, courseName: String, cb: () -> ()) {
        self.DBAccess!.addCourseToUser(userID, courseName: courseName, callback: cb)
    }
    
    /**
        This function is called if the user disenrolls from a class
        * It has a callback function that makes sure that the class is deleted from the tableViewCell
        
        :param:  userID  the userID of the current user
        :param:  courseName  the name of the course he wishes to disenroll from
        :param:  index  the indexPath of that course on the TableView
    */
    func deleteCourseFromUserAD(userID: String, courseName: String, index: NSIndexPath, cb: (NSIndexPath) -> ()) {
        self.DBAccess!.deleteCourseFromUser(userID, courseName: courseName, index: index, callback: cb)
    }
    
    /**
        This function updates the cell information of the class
        * It takes a courseName and returns the number of sessions and the total amount of people in all sessions for that class
        * The callback sets the information on the cell
        
        :param:  courseName  the name of the course whose information should be found
        :param:  cell  the cell that should be updated
    */
    func updateCellAD(courseName: String, cell: UITableViewCell, cb:(Int, Int, UITableViewCell) -> ()) {
        self.DBAccess!.updateCell(courseName, cell: cell, callback: cb)
    }
    
    /**
        This function checks if a user is in a session.
        * This has to happen when a user reopns the app after he closed it
        * Only performs callback funciton if user corresponding to userID is not in session
        * It is used to handle edge cases such as only sending a push notification to a user
        * if he/she is not in the session
        
        :param:  userID  the userID of the currentUser
        :param:  sessionID  the session that is to be checked
    */
    func isUserInSessionAD(userID: String, seshID: String, cb: (String, String) -> ()) {
        self.DBAccess!.isUserInSession(userID, sessionID: seshID, cb: cb)
    }
    
    /**
        This function handles the session joining by a user
        
        :param:  sessionID  the session that will be joined
        :param:  userID  the userID of the current user
    */
    func joinSessionAD(sessionID: String, userID: String, cb: () -> ()) {
        self.DBAccess!.joinSession(sessionID, userID: userID, callback: cb)
    }
    
    /**
        This function adds a session, when the user creates a new session. 
        * It returns a callback with the session information as a dictionary
        
        :param:  userID  the userID of the user creating the session
        :param:  courseName  the name of the course that the user is creating the session for
        :param:  description  the description of the session
        :param:  location  the location written by the user
        :param:  geoTag  the geoLocation from the map
    */
    func addSessionAD(userID: String, courseName: String, description: String, location:String, geoTag: CLLocationCoordinate2D, cb: ([String: String]) -> ()) {
        self.DBAccess!.addSession(userID, courseName: courseName, description: description, location: location, geoTag: geoTag, callback: cb)
    }
    
    /**
        This functions takes a classID and returns the information about all the sessions
        * It converts the object information to a list of dictionaries about the sessions
        * It has a callback that takes a list of dictionaries. One dictionary for every session
        
        :param: fromID  the classID
    */
    func getSessionInfoAD(fromID: String, cb:([[String: String]]) -> ()){
        self.DBAccess!.getSessionInfo(fromID, callback: cb)
    }
    
    /**
        This functions takes courseName and returns the information about all the sessions
        * It converts the object information to a list of dictionaries about the sessions
        * It has a callback that takes a list of dictionaries. One dictionary for every session
        
        :param: courseName  the courseName
    */
    func getSessionsAD(courseName: String, cb: ([[String: String]]) -> ()) {
        self.DBAccess!.getSessions(courseName, callback: cb)
    }
    
    /**
        This function makes the user leave the session when he hits the leave button
        
        :param:  userID  the userId of the current user
        :param:  sessionID  the session to be left
    */
    func leaveSessionAD(userID: String, sessionID: String, cb: () -> ()) {
        self.DBAccess!.leaveSession(userID, sessionID: sessionID, callback: cb)
    }
    
    /**
        Ths function takes a session and returns the users in the callback
        * It returns a list of tuples (username, userID)
        
        :param: sessionID the sessionID of the session to be checked
    */
    func getSessionUsersAD(sessionID: String, cb: ([(String, String)]) -> ()) {
        self.DBAccess!.getSessionUsers(sessionID, callback: cb)
    }
    
    /**
        This function queries the database for the pictures of the users that were initially stored
        * It has a callback function that returns a dictionary of (userID: image)
        
        :param:  userIDs  a list of userIDs
    */
    func getSessionUsersPicturesAD(userIDs: [String], cb: ([String: UIImage]) -> ()) {
        self.DBAccess!.getSessionUsersPictures(userIDs, callback:cb)
    }
    
    /**
        This method (and the corresponding application:willFinishLaunchingWithOptions: method) complete the app’s 
        initialization and make all final tweaks.
    */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.setupParse()       // Set Parse Application keys and enable local datastore
        self.setupDBAccess()    // Setup local datastore
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
        // Set up Facebook
        PFFacebookUtils.initializeFacebook()
        
        
        // Set up Google Maps Services Key
        GMSServices.provideAPIKey("AIzaSyCg7Pfd0VZi559Ofjn5tKGeB8UK8q24-Wc")

        
        if localData.getSessionID() != ""{
            self.go_to_locked()
            return true
        } // Else if the user has already signed in before
        else if localData.getUserID() != ""{
            self.go_to_masterview()
            return true
        } // If none of above apply, log in through facebook
        else{
            self.go_to_login()
            return true
        }
    }
    
    /**
        This function directs the user to the LoginViewController.
    */
    func go_to_login(animated: Bool = false) {
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        //checks if this is the first time the user ever launches, if it is, then we have to run the onboarding
        var firstRun = true //isFirstRun()
        let navController = self.window!.rootViewController as! UINavigationController
        self.window?.makeKeyAndVisible()
        //specify the storyboard and the location of teh storyboard to start
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("loginStoryBoardID") as! LoginViewController
        vc.isFirstRun = firstRun
        navController.pushViewController(vc, animated: animated)
    }
    
    /**
        This function directs the user to the OnboardingViewController.
    */
    func go_to_onboarding(animated: Bool = false) {
        self.window?.makeKeyAndVisible()
        let navController = self.window!.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("OnboardingViewController") as! OnboardingViewController
        navController.pushViewController(vc, animated: true)
    }
    
    /*
        If the user is invited into a session, we check that the session is still there, if it is this is executed.
        * It has a callback that is executed once the session information is gotten out of the database
        
        :param:  seshid  the id the session he is in 
    */
    func go_to_locked_from_push(seshid: String){
        self.getSessionInfoAD(seshid, cb: self.getSessionInfoCallback)
    }
    
    /*
        The callback that is the run once the session information is extracted. User is sent immediately to
        the SessionLockedViewController.
    */
    func getSessionInfoCallback(session: [[String: String]]) {
        self.session = session[0]
        self.window?.makeKeyAndVisible()
        let navController = self.window!.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("sessionLockedStoryBoardID") as! SessionLockedViewController
        vc.session = self.session
        navController.pushViewController(vc, animated: false)
    }
    
    /*
        If the user opens and is already in a session then we have to push him automatically to that locked session
        * This is the same as the function above, except that we have to get the sessionID from local data
        * It has a callback that is executed once the session information is gotten out of the database
        
        :param:  seshid  the id the session he is in
    */
    func go_to_locked(){
        self.getSessionInfoAD(localData.getSessionID(), cb: self.getSessionInfoCallback)
    }
    
    /**
        This function is called if the app is opened and the user has already logged in and is not currently in a session.
        * It displays the classes he is enrolled in
    */
    func go_to_masterview(animated: Bool = false){
        self.window?.makeKeyAndVisible()
        let navController = self.window!.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("masterViewStoryBoardID") as! MasterViewController
        navController.pushViewController(vc, animated: animated)
    }
    
    /* 
        If the user is invited to a session but the session no longer exists (everyone else left) we ask the user 
        if she wants to create a new session.
        * If he presses create, he is automatically segued to the createView
    */
    func go_to_create_from_push(courseName: String){
        self.window?.makeKeyAndVisible()
        let navController = self.window!.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("createViewStoryBoardID") as! SessionCreationViewController
        vc.courseName = courseName
        navController.pushViewController(vc, animated: false)
    }
    
    /* 
        This function handles registering push notifications
    */
    func registerPushNotifications(application: UIApplication){
        // Register for Push Notitications, if running iOS 8
        if application.respondsToSelector("registerUserNotificationSettings:") {
            
            let types:UIUserNotificationType = (.Alert | .Badge | .Sound)
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        } else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotifications()

        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // Error handled elsewhere
    }
    
    /*
        If the user clicked to join a session that no longer exists (if he was invited) then this function handles it.
        * If the session still exists he is simply pushed to the session
        * If the session doesn't exist an alert is triggered

        :param:  userid  the userID of the current user
        :param:  seshid  the id of the session he was invited to
        :param:  courseName  the name of the course he was invited to
        :param:  message  the message to be displayed
        :param:  seshStillExists  a boolean specifying whether or not the session still exists in the database
    */
    func handleClickedJoin_AfterEmptySession(userid: String, seshid: String, courseName: String, message: String, seshStillExists: Bool){
        if seshStillExists {
            self.joinSessionAD(seshid, userID: userid, cb: {})
            self.go_to_locked_from_push(seshid)
        } else {
            self.alertSessionNoLonger(courseName)
        }
        
    }
    
    /*
        This function tirggers the alert if the session that the user was invited to and accepted no longer exists
        
        :param:  courseName  the name of the course
    */
    func alertSessionNoLonger(courseName: String){
        let alert = UIAlertController(title: "Sorry", message: "Session no longer exists, create one and invite your friends", preferredStyle: .Alert)
        let createAction = UIAlertAction(title: "Create", style: .Default) { action -> Void in
            self.go_to_create_from_push(courseName)
        }
        alert.addAction(createAction)
        let closeAction = UIAlertAction(title: "Dismiss", style: .Cancel) { action -> Void in
        }
        alert.addAction(closeAction)
        let navController = self.window!.rootViewController as! UINavigationController
        navController.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
        This function handles everything if the user is invited to join a new session
        
        :param:  userid  the userID of the current user
        :param:  seshid  the id of the session he was invited to
        :param:  courseName  the name of the course he was invited to
        :param:  message  the message to be displayed
        :param:  seshStillExists  a boolean specifying whether or not the session still exists in the database
    */
    func handlePushInviteCallback(userid: String, seshid: String, courseName: String, message: String, seshStillExists: Bool) {
        // If session still exists prompt to join or dismiss
        if seshStillExists {
            let alert = UIAlertController(title: "Hello", message: message, preferredStyle: .Alert)
            let joinAction = UIAlertAction(title: "Join", style: .Default) { action -> Void in
                //we enroll the user in the class for the session
                self.addCourseToUserAD(userid, courseName: courseName, cb: {})
                if self.localData.getSessionID() != "" {   // if user already in a session, remove him/her before joining new session
                    self.leaveSessionAD(self.localData.getUserID(), sessionID: self.localData.getSessionID(), cb: {() -> Void in})
                }
                self.sessionExists_afterPromptAD(userid, seshid: seshid, courseName: courseName, message: "")
            }
            alert.addAction(joinAction)
            let closeAction = UIAlertAction(title: "Dismiss", style: .Cancel) { action -> Void in
            }
            alert.addAction(closeAction)
            let navController = self.window!.rootViewController as! UINavigationController
            navController.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.alertSessionNoLonger(courseName)
        }
    }
    
    
    /**
        This functions returns true iff there is an active network connection.
        Heavily influenced by http://stackoverflow.com/questions/25398664/check-for-internet-connection-availability-in-swift
    */
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
    
    /**
        This functions returns true iff it is the first time the user has run the application.
    */
    func isFirstRun() -> Bool {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("isFirstRun" ) != nil) {
            return false
        }
        defaults.setObject(NSDate(), forKey: "isFirstRun")
        defaults.synchronize()
        return true
    }
    
    /**
        This function handles received push notification.
    */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        var message = userInfo["message"] as! String
        var seshid = userInfo["seshid"] as! String
        var courseName = userInfo["courseName"]as! String
        var userid = localData.getUserID()
        self.sessionExists_beforePromptAD(userid, seshid: seshid, courseName: courseName, message: message)
        
    }
    
    /**
        Checks whether or not a user is in a current session or not when receiving a push notification before
        user being prompted.
    */
    func sessionExists_beforePromptAD(userid: String, seshid: String, courseName: String, message: String){
        self.DBAccess!.sessionExists(userid, sessionID: seshid, courseName: courseName, message: message, cb: self.handlePushInviteCallback)
    }
    
    /**
        Checks whether or not a user is in a current session or not when receiving a push notification after
        user being prompted.
    */
    func sessionExists_afterPromptAD(userid: String, seshid: String, courseName: String, message: String){
        self.DBAccess!.sessionExists(userid, sessionID: seshid,  courseName: courseName, message: message, cb: self.handleClickedJoin_AfterEmptySession)
    }
    
    /**
        Sends a push iff the user is in a session. Done through communications with the DatabaseAccess class.
    */
    func sendPushCallback(userid: String, course: String) {
        self.DBAccess!.sendPushCallback(userid, course: course)
    }

    /**
        Registers user to receive notifications.
    */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.addUniqueObject("a"+localData.getUserID(), forKey: "channels")
        installation.saveInBackground()
    }
    
    /**
        Handles FBAppCall
        * Required for Facebook Login
    */

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        var wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication, withSession: PFFacebookUtils.session())
        return wasHandled
    }
    
    /**
        Handles when the application became active
        * Required for Facebook Login
    */
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppEvents.activateApp()
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }
    
    
    // -------------------------------- AUTOGENERATED BY XCODE --------------------------------
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, isable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        FBSession.activeSession().close()
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Casa.Cramr_v2_0" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Cramr_v2_0", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Cramr_v2_0.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}


