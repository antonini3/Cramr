//
//  LocalDatastore.swift
//  Cramr v2.0
//
//  Created by Anton Apostolatos on 2/19/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import Foundation

/**
    This class coordinates our interaction with the local datastorage. It pins information that we need "cached".
    Mostly information to do with the user, such as:
    * userID
    * username
    * sessionID
    * enrolledCourses
*/
class LocalDatastore {
    
    var user: PFObject!
    
    var enrolledCourses: [String]!
    
    /**
    This function is the callback function for the database call
    * It sets the courselist with a new courselist

    :param:  courseList  a list of strings, that specifiy the new enrolled courses to be set
    :param:  tableReload  a boolean that specifies whether or not the tableview should be reloaded or not
    */
    func resetEnrolledCoursesCallback(courseList: [String], tableReload: Bool) {
        self.enrolledCourses = courseList
    }
    
    /**
    This function sets the enrolled course list

    :param:  courseList  a list of strings, which are the enrolled courses to be set
    */
    func setEnrolledCourses(courseList: [String]) {
        self.enrolledCourses = courseList
    }
    
    /**
    This function resets the enrolled courses
    * It calls the current courses from the database
    * and reloads it with the a new courselist in its callback
    */
    func resetEnrolledCourses() {
        (UIApplication.sharedApplication().delegate as! AppDelegate).getCoursesFromAD((UIApplication.sharedApplication().delegate as! AppDelegate).localData.getUserID(), tableReload: false, cb: resetEnrolledCoursesCallback)
    }

    /**
    This function returns the current enrolled courses of a user
    
    :returns:  enrolledCourses  a list of strings, which are the enrolled courses
    */
    func getCourseList() -> [String] {
        return self.enrolledCourses
    }
    
    /** 
    This function adds a course to the enrolled courses of the current user

    :param:  course  the course to be added
    */
    func addCourse(course: String) {
        // why do we get the course list here and not store it in a variable? Is this not superflous?
        getCourseList()
        self.enrolledCourses.append(course)
    }
    
    /**
    This function deletes a specific course from the courseList
    * If the course is not in the list, it doesn't do anything

    :param:  course  a string which specifies the course to delete
    */
    func deleteCourse(course: String) {
        var index = find(getCourseList(), course)
        if index != nil {
            self.enrolledCourses.removeAtIndex(index!)
        }
    }
    
    /**
    This function initializes the user
    * It sets the current user to nill
    * It sets the enrolled courses of the current user to nil

    :returns: a new user
    */
    init() {
        self.user = nil
        self.enrolledCourses = nil
    }
    
    /**
    This function initially printed out userID and sessionID for debugging purposes
    */
    func printInfo() {
        var u = self.user["userID"] as! String
        var s = self.user["sessionID"] as! String
        //        NSLog("User ID: " + u)
        //        NSLog("Sesh ID: " + s)
    }
    
    /**
    This function sets up parse.
    * It enables local datastorage
    * It sets the applicationID and the clientKey
    */
    func setupParse() {
        Parse.enableLocalDatastore()
        Parse.setApplicationId("sXNki6noKC9lOuG9b7HK0pAoruewMqICh8mgDUtw", clientKey: "Gh80MLplqjiOUFdmOP2TonDTcdmgevXbGaEhpGZR")
    }
    
    /** 
    This function deletes the current session
    * It does this by setting the current session to the empty string
    */
    func deleteSession(){
        self.setSession("")
    }
    
    /** 
    This function sets the UserID of the current user and the new session
    
    * It then pins the user in the background
    
    :param:  userID  the userID as string
    :param:  sessionID the sessionID as string
    */
    func setUserSession(userID: String, sessionID: String) {
        var loggedUser = self.getUser()
        loggedUser["userID"] = userID
        loggedUser["sessionID"] = sessionID
        self.printInfo()
        loggedUser.pinInBackground()
        
    }
    
    /** 
    This function sets the userID of the current user
    * It then pins the user in the background

    :param:  userID  the userID as string
    */
    func setUserID(userID: String) {
        var loggedUser = self.getUser()
        loggedUser["userID"] = userID
        loggedUser.pinInBackground()
    }
    
    /**
    This function sets the username of the current user
    * It then pins the user in the background
    
    :param:  username  the username as string
    */
    func setUserName(username: String){
        var loggedUser = self.getUser()
        loggedUser["username"] = username
        loggedUser.pinInBackground()
    }
    
    /**
    This function sets a new session for the current user
    * It then pins the user in the background

    :param:  sessionID  the new sessionID as string
    */
    func setSession(sessionID: String) {
        var loggedUser = self.getUser()
        loggedUser["sessionID"] = sessionID
        self.printInfo()
        loggedUser.pinInBackground()
    }
    
    /** 
    This function extracts the userID from the current user

    :returns: userID string
    */
    func getUserID() -> String {
        return self.getUser()["userID"] as! String
    }
    
    /** 
    This function extracts the username from the current user

    :returns: username string
    */
    func getUserName() -> String{
        return self.getUser()["username"] as! String
    }
    
    /** 
    This function extracts the current sessionID from the current user

    :returns: sessionID string
    */
    func getSessionID() -> String {
        return self.getUser()["sessionID"] as! String
    }
    
    func setImageURL(imageURL: String) {
        var loggedUser = self.getUser()
        loggedUser["imageURL"] = imageURL
        loggedUser.pinInBackground()
    }
    
    func getImageURL() -> String {
        return self.getUser()["imageURL"] as! String
    }
    
    
    /**
    This function returns the current user.
    * If the current user is not nil, he is returned.
    * If the current user is nil, then the datebase is queried for the first logged user.
    * If no user is found, a new user is assigned to the self.user, with no information.

    :returns: a PFObject that is the user
    */
    private func getUser() -> PFObject {
        if self.user == nil {
            let query = PFQuery(className: "LoggedUsers")
            query.fromLocalDatastore()
            self.user = query.getFirstObject()
            if self.user == nil {
                self.user = PFObject(className: "LoggedUsers")
                self.user["userID"] = ""
                self.user["sessionID"] = ""
                self.user["username"] = ""
                self.user["imageURL"] = ""
            }
        }
        self.printInfo()
        return self.user
    }
}
