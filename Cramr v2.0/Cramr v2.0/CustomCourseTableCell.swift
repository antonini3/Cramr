//
//  CustomCourseTableCellController.swift
//  Cramr v2.0
//
//  Created by Roberto Alvarez on 2/19/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import Foundation

/**
    This class is the view for our custom course cells in the master view. It is responsible for displaying the icons indicating the number of people and sessions, or the plus sign if the group is empty, as well the course name.
*/
class CustomCourseTableCell: UITableViewCell {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentView.backgroundColor = .clearColor()
        
    }
    
    var blurAdded: Bool = false
    
    
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var numPeopleLabel: UILabel!
    @IBOutlet weak var numSessionsLabel: UILabel!
    
    @IBOutlet weak var plusIcon: UIImageView!
    @IBOutlet weak var peopleIcon: UIImageView!
    @IBOutlet weak var bookIcon: UIImageView!
    
    /**
        This function adds a blur effect to the cell.
    */
    func addCellBlur() {
        addBlur(self.contentView, [self.contentView])
        for subView in [self.courseNameLabel, self.numPeopleLabel, self.numSessionsLabel, self.plusIcon, self.peopleIcon, self.bookIcon] {
            self.contentView.bringSubviewToFront(subView)
        }
        self.blurAdded = true
    }
    
    /**
        This function is called by the MasterViewController to update the coursename in a sell.
        * It takes a string with the course name.
    
        :param: courseName the name of the course to be displayed
    */
    func updateCellName(courseName: String) {
        self.courseNameLabel?.adjustsFontSizeToFitWidth = true
        self.courseNameLabel?.text = getCourseID(courseName)
    }
    
    /**
        This function is called to update the numbers on the right side of the cell.
        * It takes the number of people in a session as well as the number of sessions and displays the proper numbers (or an 'add' sign if the numbers are zero.

        :param:  numPeople  the number of people in an active study session
        :param:  numSessions  the number of active study sessions
    */
    func updateCellContents(numPeople: Int, numSessions: Int) {
        self.courseNameLabel?.adjustsFontSizeToFitWidth = true
        self.numSessionsLabel.text = String(numSessions)
        self.numPeopleLabel.text = String(numPeople)
        
        self.numPeopleLabel.hidden = numSessions == 0
        self.numSessionsLabel.hidden = numSessions == 0
        self.bookIcon.hidden = numSessions == 0
        self.peopleIcon.hidden = numSessions == 0
        self.plusIcon.hidden = numSessions != 0
        
        if !blurAdded {
            //addCellBlur() //Currently choosing not to add blur
        }
    }
    
}