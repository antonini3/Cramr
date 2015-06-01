//
//  SchoolTableView.swift
//  Cramr v2.0
//
//  Created by Anton Apostolatos on 1/29/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import UIKit
import Foundation

/**
    This class is is the view controller for choosing courses that you are enrolled in
    It requests information from the datebase and displays and it has a search function
*/
class CourseListTableView: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var courseTable: UITableView!
    
    @IBOutlet weak var classSearch: UISearchBar!
    
    //to make calling the appDelegate easier, which we need for interacting with the database
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var courses = []
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    
    /**
        This function is the callback for the search.
        * It sets the courses that were returned from the query as the courses variable, to construct the table
        * It reloads teh data in the table view, to make sure that the courses are displayed
    */
    func courseListCallback(courses: [String]) {
        self.courses = courses
        self.courseTable.reloadData()
    }

    /**
        This function queries the database for the courses that math the query
        * It reacts to the when the text change in teh searchbar
    */
    func searchBar(_classSearch: UISearchBar, textDidChange searchText: String) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).getCourseListFromAD(searchText, cb: courseListCallback)
    }
    
    func setupSearch() {
        classSearch.delegate = self
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /**
        This function displays the information for this view
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearch()
        //It sets up the table view that we need
        self.courseTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // self.getParseData()
        
        // and it makes sure that the view looks as we want it to
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.translucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clearColor()
//        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        view.backgroundColor = .whiteColor()
        self.courseTable.alpha = 0.9
        self.courseTable.tableFooterView = UIView()
        
        self.classSearch.layer.borderWidth = 1
        self.classSearch.layer.borderColor = cramrBlue.CGColor

    }
    
    // TABLE VIEW FUNCTIONS
    
    /**
        This function returns the size of table view, which is the number of rows
        * The number of rows is the number courses

        :param:  tableView  the tableView that we want this information from
        :param:  section  the section to check

        :returns: an integer that is the number of rows in that section
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count;
    }
    
    /**
        This function sets the content of a specific cell and the returns the cell

        :param:  tableView  the tableView that we want to edit
        :param:  indexPath  the current index that in the table view that we want to edit

        :returns: a UITableViewCell which has had its content set
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.courseTable.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        cell.textLabel?.text = self.courses[indexPath.row] as? String
        cell.contentView.backgroundColor = .whiteColor()
        cell.textLabel?.textColor = cramrBlue
        return cell
    }
    
    func selectedRowCallBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
        This function sets the course that was seletected to the current user information
    
        :param:  tableView
        :param:  indexPath  the index of the selection, to get the name of course
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // checks for network connecttivity
        if self.appDelegate.isConnectedToNetwork() {
            //It takes the courses that was selected
            (UIApplication.sharedApplication().delegate as! AppDelegate).addCourseToUserAD((UIApplication.sharedApplication().delegate as! AppDelegate).localData.getUserID(), courseName: self.courses[indexPath.row] as! String, cb: selectedRowCallBack)
        } else {
            //If there is no network it deselects the row to make sure nothing happens once connectivity is restored
            checkForNetwork(self, self.appDelegate, message: "")
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

}
