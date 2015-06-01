//
//  DatabaseAccess.swift
//  Cramr v2.0
//
//  Created by Anton Apostolatos on 2/24/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import Foundation
import CoreData

class DatabaseAccess {
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    /**
        This function signs up the user in the database.
        * It takes a FBGraphUser and if the user doesn't exist yet he is signed up

        :param:  user  a FBGraphUser that should be signed up
    */
    func signupUser(user: FBGraphUser, callback: () -> ()) {
        var query = PFUser.query();
        query.whereKey("userID", containsString: user.objectID)
        query.findObjectsInBackgroundWithBlock {
            (users: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                //checks to make sure user isn't there yet
                if users.count == 0 {
                    //NSLog("Grabbing picture!")
                    var parse_user = PFUser()
                    //specifies the information that is necessary for a user
                    parse_user.username = user.name
                    parse_user.password = ""
                    parse_user.email = user.objectForKey("email") as! String
                    parse_user["userID"] = user.objectID
                    
                    //grabs the image from facebook and stores it as a UIImage
                    var imageData : UIImage!
                    let url: NSURL? = NSURL(string: "https://graph.facebook.com/\(user.objectID)/picture/?type=large")
                    if let data = NSData(contentsOfURL: url!) {
                        imageData = UIImage(data: data)
                    }
                    let image = UIImagePNGRepresentation(imageData)
                    //stores it in the database as a PFFile in the UserPhoto class
                    let imageFile = PFFile(name:"profilepic.png", data:image)
                    var userPhoto = PFObject(className:"UserPhoto")
                    userPhoto["imageName"] = "Profile pic of \(user.objectID)"
                    userPhoto["imageFile"] = imageFile
                    parse_user["image"] = userPhoto
                    
                    //finishes signup in background
                    parse_user.signUpInBackground()
                }
            } else {
                // Log details of the failure
                NSLog("Error in signupUser: %@ %@", error, error.userInfo!)
            }
        }
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
    func isUserInSession(userID: String, sessionID: String, cb: (String, String) -> ()) {
        //first queries to get the right session
        var query = PFQuery(className: "Sessions")
        query.getObjectInBackgroundWithId(sessionID) {
            (object: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                var session = object as! PFObject
                //gets the active users from that session
                var users = session.objectForKey("active_users") as! [String]
                var courseName = session.objectForKey("course") as! String
                //queries for the user by userID
                var userQuery : PFQuery = PFUser.query()
                userQuery.whereKey("userID", containedIn: users)
                userQuery.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        var found = false
                        var users = objects as! [PFObject]
                        var usersTupleArray = [(String, String)]()
                        // For each user in the session's users, check that our userID is not there
                        for user in users {
                            var other_user_id = user["userID"] as! String
                            if userID == other_user_id{
                                found = true
                            }
                        }
                        // If we did not find a userID, then call the callback function
                        if found == false{
                            cb(userID, courseName)
                        }
                    }
                }
                
            } else {
                // Log details of the failure
                NSLog("Error in isUserInSesssion: %@ %@", error, error.userInfo!)
            }
        }
        
    }

    /**
        This function checks whether a session Exists
        * It is necessary because a user may have recieved a push notification from a session, but only opens it once the session has already been deleted
        * It returns a callback that specifies the four parameters below and a boolean weather or not the session was found
        
        :param: userID  the user that has been invited
        :param: sessionID  the session that he is invited to
        :param: courseName  the course that the seession is in
        :param: message  the message to be displayed to the user in case the session is no longer there
    */
    func sessionExists(userid: String, sessionID: String, courseName: String, message: String, cb: (String, String, String, String, Bool) -> ()){
        var query = PFQuery(className: "Sessions")
        query.getObjectInBackgroundWithId(sessionID) {
            (object: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                //If the session IS found, the callback function is called with true
                cb(userid, sessionID, courseName, message, true)
            }
            else {
                //If the session IS not found, the callback function is called with false
                if error.code == kPFErrorObjectNotFound {
                     cb(userid, sessionID, courseName, message, false)
                }
                println("Ignore the Parse error in the log above, we handle no results matched the query")
            }
        }
    }

    /**
        Ths function takes a session and returns the users in the callback
        * It returns a list of tuples (username, userID)
        
        :param: sessionID the sessionID of the session to be checked
    */
    func getSessionUsers(sessionID: String, callback: ([(String, String)]) -> ()) {
        var query = PFQuery(className: "Sessions")
        //find the session
        query.getObjectInBackgroundWithId(sessionID) {
            (object: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                var session = object as! PFObject
                //gets the active users
                var users = session.objectForKey("active_users") as! [String]
                //then queries for the user
                var userQuery : PFQuery = PFUser.query()
                
                userQuery.whereKey("userID", containedIn: users)
                //finds all the users whose userID were specified
                userQuery.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        var users = objects as! [PFObject]
                        var usersTupleArray = [(String, String)]()
                        for user in users {
                            var userName = user["username"] as! String
                            var userID = user["userID"] as! String
                            var tup = (userName, userID)
                            usersTupleArray.append(tup)
                        }
                        callback(usersTupleArray)
                    }
                }
                
            } else {
                // Log details of the failure
                println("what the fuck") //can we take this out now?
                NSLog("Error in getSessionUsers: %@ %@", error, error.userInfo!)
            }
        }
        
    }

    /**
        This function queries the database for the pictures of the users that were initially stored
        * It has a callback function that returns a dictionary of (userID: image)
        
        :param:  userIDs  a list of userIDs
    */
    func getSessionUsersPictures(userIDs: [String], callback: ([String: UIImage]) -> ()) {
        var userImages = [String: UIImage]()
        //queries every userID separetely
        for userID in userIDs {
            var local_query = PFQuery(className: "UserPictures")
            local_query.fromLocalDatastore()
            local_query.whereKey("userID", equalTo: userID)
            local_query.getFirstObjectInBackgroundWithBlock {
                (object: AnyObject!, error: NSError!) -> Void in
                if object != nil { // checks if saved locally
                    var obj = object as! PFObject
                    let userImage = UIImage(data: obj["imageData"] as! NSData)
                    userImages[userID] = userImage
                    if userImages.count == userIDs.count {
                        callback(userImages)
                    }
                    
                } else { // Query from Database
                    var query = PFQuery(className: "UserPhoto")
                    query.whereKey("imageName", containsString: userID)
                    query.findObjectsInBackgroundWithBlock {
                        (objects: [AnyObject]!, error: NSError!) -> Void in
                        if error == nil {
                            let userPhoto = objects[0] as! PFObject
                            let userImageFile = userPhoto["imageFile"] as! PFFile
                            //extracts data
                            userImageFile.getDataInBackgroundWithBlock {
                                (imageData: NSData!, error: NSError!) -> Void in
                                if error == nil {
                                    let image = UIImage(data:imageData)
                                    userImages[userID] = image
                                    //pins image for later use
                                    self.pinImageInBackground(userID, imageData: imageData)
                                    if userImages.count == userIDs.count {
                                        callback(userImages)
                                    }
                                    
                                } else  {
                                    NSLog("Error in inner getSessionUsersPictures: %@ %@", error, error.userInfo!)
                                }
                            }
                        } else  {
                            NSLog("Error in outer getSessionUsersPictures: %@ %@", error, error.userInfo!)
                        }
                    }
                }
            }
        }
    }
    
    func getUserPictureURL(userID: String, callback: (String) -> ()) {
        //queries every userID separetely
        var query = PFQuery(className: "UserPhoto")
        query.whereKey("imageName", containsString: userID)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                let userPhoto = objects[0] as! PFObject
                let userImageFile = userPhoto["imageFile"] as! PFFile
                callback(userImageFile.url)
            } else  {
                NSLog("Error in getUserPictureURL: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    /**
        Pins the image in the background.
    */
    func pinImageInBackground(userID: String, imageData: NSData) {
        var pfObj = PFObject(className: "UserPictures")
        pfObj["userID"] = userID
        pfObj["imageData"] = imageData
        pfObj.pinInBackground()
    }
    
    /**
        This function makes the user leave the session when he hits the leave button
        
        :param:  userID  the userId of the current user
        :param:  sessionID  the session to be left
    */
    func leaveSession(userID: String, sessionID: String, callback: () -> ()) {
        //queries for the session
        var query = PFQuery(className: "Sessions")
        query.getObjectInBackgroundWithId(sessionID) {
            (object: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                var session = object as! PFObject
                var users = session.objectForKey("active_users") as! [String]
                users.removeAtIndex(find(users, userID)!)
                //if there are still users in the session, then the list of active users is replaced with the list without the user that was removed and the new list is saved
                if users.count > 0 {
                    session["active_users"] = users
                    session.saveInBackground()
                //if there are no more users in the session, the session is deleted
                } else {
                    session.deleteInBackground()
                }
                //and the session is deleted out of local data because it has been updated and is therefore no longer current
                (UIApplication.sharedApplication().delegate as! AppDelegate).localData.deleteSession()
                callback()
            } else {
                // Log details of the failure
                NSLog("Error in leaveSession: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    /** 
        This functions takes a classID and returns the information about all the sessions
        * It converts the object information to a list of dictionaries about the sessions
        * It has a callback that takes a list of dictionaries. One dictionary for every session
        
        :param: fromID  the classID
    */
    func getSessionInfo(fromID: String, callback:([[String: String]]) -> ()){
        var sessionQuery = PFQuery(className: "Sessions")
        sessionQuery.whereKey("objectId", equalTo: fromID)
        sessionQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var sessions = [[String: String]]()
                var parseSessions = objects as! [PFObject]
                //each session is processed
                for object in parseSessions {
                    //convertToSessionDict takes six strings (sessionID, descirption, location, courseName, latitute, longitude) and returns it as a dictionary from that title to the actual information
                    sessions.append(convertToSessionDict(object.objectId, object["description"] as! String, object["location"] as! String, object["course"] as! String, object["latitude"] as! String, object["longitude"] as! String))
                }
                callback(sessions)
            } else {
                // Log details of the failure
                NSLog("Error in getSessionInfo: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    /**
        This functions takes courseName and returns the information about all the sessions
        * It converts the object information to a list of dictionaries about the sessions
        * It has a callback that takes a list of dictionaries. One dictionary for every session
        
        :param: courseName  the courseName
    */
    func getSessions(courseName: String, callback: ([[String: String]]) -> ()) {
        var sessionQuery = PFQuery(className: "Sessions")
        sessionQuery.whereKey("course", equalTo: courseName)
        
        sessionQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var sessions = [[String: String]]()
                var parseSessions = objects as! [PFObject]
                for object in parseSessions {
                    //convertToSessionDict takes six strings (sessionID, descirption, location, courseName, latitute, longitude) and returns it as a dictionary from that title to the actual information
                    sessions.append(convertToSessionDict(object.objectId, object["description"] as! String, object["location"] as! String, object["course"] as! String, object["latitude"] as! String, object["longitude"] as! String))
                }
                callback(sessions)
            } else {
                // Log details of the failure
                NSLog("Error in getSessions: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    /**
        Handles and sends the push notification
    
        :param:  userid  the userID of the user being sent the push notification
        :param:  course  the course of the session the user is being invited to
    */
    func sendPushCallback(userid: String, course: String) {
        let push = PFPush()
        push.setChannel("a"+userid)
        
        let data = [
            "alert" : self.appDelegate.localData.getUserName() + " invited you to work on " + getCourseName(course),
            "seshid" : self.appDelegate.localData.getSessionID(),
            "courseName" : course,
            "message" :self.appDelegate.localData.getUserName() + " invited you to work on " + getCourseName(course)
        ]
        push.setData(data)
        push.sendPushInBackground()
    }
    
    /**
        This function adds a session, when the user creates a new session
        * It returns a callback with the session information as a dictionary
        
        :param:  userID  the userID of the user creating the session
        :param:  courseName  the name of the course that the user is creating the session for
        :param:  description  the description of the session
        :param:  location  the location written by the user
        :param:  geoTag  the geoLocation from the map
    */
    func addSession(userID: String, courseName: String, description: String, location: String, geoTag: CLLocationCoordinate2D, callback: ([String: String]) -> ()) {
        if userID != "" {
            var new_session = PFObject(className: "Sessions")
            new_session["active_users"] = [userID]
            new_session["description"] = description
            new_session["location"] = location
            new_session["course"] = courseName
            new_session["start_time"] = NSDate()
            
            new_session["latitude"] = "\(geoTag.latitude)"
            new_session["longitude"] = "\(geoTag.longitude)"
            new_session.saveInBackgroundWithBlock {
                (success: Bool, error: NSError!) -> Void in
                if success {
                    (UIApplication.sharedApplication().delegate as! AppDelegate).localData.setSession(new_session.objectId)
                    var sessionDict: [String: String] = convertToSessionDict(new_session.objectId, description, location, courseName, new_session["latitude"] as! String, new_session["longitude"] as! String)
                    callback(sessionDict)
                    
                }
            }
        }
    }
    
    /** 
        This function handles the session joining by a user
        
        :param:  sessionID  the session that will be joined
        :param:  userID  the userID of the current user
    */
    func joinSession(sessionID: String, userID: String, callback: () -> ()) {
        var query = PFQuery(className: "Sessions")
        query.getObjectInBackgroundWithId(sessionID) {
            (object: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                var currSession = object as! PFObject
                var activeUsers = currSession["active_users"] as! [String]
                //makes sure the user is not in the session yet
                if find(activeUsers, userID) == nil {
                    activeUsers.append(userID)
                    currSession["active_users"] = activeUsers
                    currSession.save()
                } else {
                    // NSLog("User already in the session he/she is joining.")
                }
                //the the current session as this session
                (UIApplication.sharedApplication().delegate as! AppDelegate).localData.setSession(sessionID)
                callback()
            } else {
                // Log details of the failure
                NSLog("Error in joinSession: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    
    /**
        This function updates the cell information of the class
        * It takes a courseName and returns the number of sessions and the total amount of people in all sessions for that class
        * The callback sets the information on the cell

        :param:  courseName  the name of the course whose information should be found
        :param:  cell  the cell that should be updated
    */
    func updateCell(courseName: String, cell: UITableViewCell, callback: (Int, Int, UITableViewCell) -> ()) {
        var query = PFQuery(className: "Sessions")
        query.whereKey("course", equalTo: courseName)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var sessions = objects as! [PFObject]
                var numSessions = sessions.count
                var numPeople = 0
                for s in sessions {
                    numPeople += s["active_users"].count
                }
                callback(numPeople, numSessions, cell)
            }
        }
    }
    
    /**
        This function is called when the user adds a new class to his current classes
        
        :param:  userID  the userID of the current user
        :param:  courseName  the name of the course that the user is adding
    */
    func addCourseToUser(userID: String, courseName: String, callback: () -> ()) {
        var query = PFQuery(className: "EnrolledCourses")
        if userID != "" {
            query.whereKey("userID", equalTo: userID)
            //the user is found
            query.getFirstObjectInBackgroundWithBlock {
                (object: AnyObject!, error: NSError!) -> Void in
                if object != nil {
                    //then the enrolled courses array of the user is updated
                    var object_user = object as! PFObject
                    var course_array = object_user["enrolled_courses"] as! [String]
                    //we make sure he is not already in the course
                    if !contains(course_array, courseName) {
                        course_array += [courseName]
                        object_user["enrolled_courses"] = course_array
                        object_user.saveInBackground()
                    }
                } else {
                    //if the course is not found, then we manually add him too that course
                    var new_object_user = PFObject(className: "EnrolledCourses")
                    new_object_user["userID"] = userID
                    new_object_user["enrolled_courses"] = [courseName]
                    new_object_user.saveInBackground()
                }
                callback()
            }
        }
    }
    
    /**
        This function is called if the user disenrolls from a class
        * It has a callback function that makes sure that the class is deleted from the tableViewCell
        
        :param:  userID  the userID of the current user
        :param:  courseName  the name of the course he wishes to disenroll from
        :param:  index  the indexPath of that course on the TableView
    */
    func deleteCourseFromUser(userID: String, courseName: String, index: NSIndexPath, callback: (NSIndexPath) -> ()) {
        var query = PFQuery(className: "EnrolledCourses")
        if userID != "" {
            query.whereKey("userID", equalTo: userID)
            query.getFirstObjectInBackgroundWithBlock {
                (object: AnyObject!, error: NSError!) -> Void in
                if error == nil {
                    if object != nil {
                        var object_user = object as! PFObject
                        object_user["enrolled_courses"].removeObject(courseName)
                        object_user.saveInBackground()
                    }
                    callback(index)
                } else {
                    // Log details of the failure
                    NSLog("Error in deleteCourseFromUser: %@ %@", error, error.userInfo!)
                }
            }
        }
    }
    
    /**
        This function gets the courses the user is in to display on the course TableView
        * It has a callback that sends the courses that the user is enrolled in and information whether the courselist should be reloaded or not
        
        :param:  userID  the userID of the current user
        :param:  tableReload  a boolean specifiying whether or not the table should be reloaded after the update
    */
    func getCourses(userID: String, tableReload: Bool, callback: ([String], Bool) -> ()) {
        var query_courses = PFQuery(className: "EnrolledCourses")
        query_courses.whereKey("userID", equalTo: userID)
        query_courses.getFirstObjectInBackgroundWithBlock {
            (object: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                var course = object as! PFObject
                var enrolled_courses = course["enrolled_courses"] as! [String]
                callback(enrolled_courses, tableReload)
            } else {
                // Log details of the failure
                NSLog("Error in getCourses: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    /**
        This function handles the regex, capitalization, spaces, numbers
        
        :param:  text  the query of the user
    */
    func getRegexSearchTerm(text: String) -> String {
        var searchText = text.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        if searchText == "" {
            return text
        }
        
        var regex = ""
        var spacer = "(?: )?"
        for ch in searchText {
            regex = regex + String(ch) + spacer
        }
        return regex
    }
    
    /**
        This function gets all the courses, as the user is typing, and displays them for him to enroll in a new course
        * the callback function displays the list of the courses that are to be displayed
        
        :param:  searchText  the text of the users query
    */
    func getCourseList(searchText: String, callback: ([String]) -> ()) {
        //If the user deletes everything in the query, we want to display nothing
        if searchText == "" {
            callback([])
        } else {
            var query = PFQuery(className: "Course")
            //we limit the query to 15
            query.limit = 15
            
            //we regex the query, for capitalization, spaces etc
            var regex = self.getRegexSearchTerm(searchText)
            query.whereKey("title", matchesRegex: regex, modifiers: "i")
            
            query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    var courses = objects as! [PFObject]
                    var course_titles: [String] = []
                    for c in courses {
                        course_titles.append(c["title"] as! String)
                    }
                    callback(course_titles)
                } else {
                    // Log details of the failure
                    NSLog("Error in getCourseList: %@ %@", error, error.userInfo!)
                }
                
            }
        }
    }
}
