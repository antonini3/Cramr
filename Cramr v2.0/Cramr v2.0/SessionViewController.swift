//
//  DetailViewController.swift
//  Cramr v2.0
//
//  Created by Anton Apostolatos on 1/26/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import UIKit

/** 
This class sits between the SessionBrowserViewController and the SessionContentViewController
It is the container within the SessionBrowserViewController, which contains all the SessionContentViewControllers, which display the sessions
*/
class SessionViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var sessions: [[String: String]]!
    var pageController: UIPageViewController?
    
    
    /**
        This function is called if the user presses the back button. It returns to the view of all 
        enrolled classes in the MasterViewController
    */
    @IBAction func popToSessionView(segue: UIStoryboardSegue) {
        performSegueWithIdentifier("popToBrowser", sender: self)
    }

    /**
        This function is the required init function/.
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }

    /**
        This function adds all of the session data to this controller's session array.
        
        :param:  controller  the session browser view controller that contains the sessionview
        :param:  arr  the array includin the session data
    */
    func sendSessionData(controller: SessionBrowserViewController, arr: [[String: String]]) {
        self.sessions = arr
    }
    
    /**
        This function returns the session content view controller for the chosen index of the page view controller.

        :param:  index  index of the view controller being returned
    */
    func viewControllerAtIndex(index: Int) -> SessionContentViewController? {
        if (sessions.count == 0 || index >= sessions.count) {
            return nil
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let dataViewController = storyboard?.instantiateViewControllerWithIdentifier("sessionContent") as! SessionContentViewController
        dataViewController.session = self.sessions[index]
        return dataViewController
    }
    
    
    /**
        This function returns the index of session content view controller that is passed in.
        
        :param:  viewController  view controller whose index is desired
    */
    func indexOfViewController(viewController: SessionContentViewController) -> Int {
        
        if let currentSession: [String: String] = viewController.session {
            var count = 0
            for session in sessions {
                if areEqualSessions(session, currentSession) { return count }
                count += 1
            }
        }
        return NSNotFound
    }


    /**
        This function returns the session content view controller for the bordering session content view controller before the one the user is looking at.
        
        :param:  pageViewController  the entire page view controller
        :param:  viewControllerBeforeViewController  the view controller the user is looking at
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController
            as! SessionContentViewController)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        leftSwipe = true
        return viewControllerAtIndex(index)
    }
    
//    override func setViewControllers(viewControllers: [AnyObject]!, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool) -> Void)!) {
//        super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
//        if (markerSelect == false) {
//            if (direction == UIPageViewControllerNavigationDirection.Forward) {
//                currentIndex++
//            } else {
//                currentIndex--
//            }
//            (self.parentViewController as! SessionBrowserViewController).updateMapMarker(currentIndex)
//        }
//        NSLog( "%d" , currentIndex)
//        markerSelect = false;
//    }
    
    var leftSwipe : Bool = false
    var rightSwipe : Bool = false
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
//        
//        if (!completed) {
//            return
//        }
//        
//        var currIndex = (self.pageController?.viewControllers as! [UIViewController]).last as
//        if (leftSwipe && currentIndex > 1) {
//            currentIndex--
//            (self.parentViewController as! SessionBrowserViewController).updateMapMarker(currentIndex)
//        } else if (rightSwipe && currentIndex < sessions.count - 1) {
//            currentIndex++
//            (self.parentViewController as! SessionBrowserViewController).updateMapMarker(currentIndex)
//        }
//        leftSwipe = false
//        rightSwipe = false
    
        var vc = pageViewController.viewControllers.last
        var session = (vc as! SessionContentViewController).session
        
        var index = 0
        for var i = 0; i < sessions.count; i++ {
            if (sessions[i]["sessionID"] == session["sessionID"]) {
                index = i
            }
        }
        currentIndex = index
        (self.parentViewController as! SessionBrowserViewController).updateMapMarker(currentIndex)

        
    }
    
    /**
        This function returns the session content view controller for the bordering session content view controller after the one the user is looking at.
        
        :param:  pageViewController  the entire page view controller
        :param:  viewControllerAfterViewController  the view controller the user is looking at
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController
            as! SessionContentViewController)
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        if index == sessions.count {
            return nil
        }
        rightSwipe = true
        return viewControllerAtIndex(index)
    }

    /**
        This function organizes all of the view controllers in the page view controller.
    */
    func organizeChildren() {
        pageController = UIPageViewController(
            transitionStyle: .Scroll,
            navigationOrientation: .Horizontal,
            options: nil)
        
        pageController!.delegate = self
        pageController!.dataSource = self
        
        let startingViewController: SessionContentViewController =
        viewControllerAtIndex(0)!
        
        let viewControllers: NSArray = [startingViewController]
        pageController!.setViewControllers(viewControllers as [AnyObject],
            direction: .Forward,
            animated: false,
            completion: nil)
        
        self.addChildViewController(pageController!)
        self.view.addSubview(self.pageController!.view)
        
        var pageViewRect = self.view.bounds
        pageController!.view.frame = pageViewRect
        pageController!.didMoveToParentViewController(self)
        
        currentIndex = 0
    }
    
    var currentIndex : Int = 0
    
    
    func goToView(index: Int) {
        NSLog( "%d" , currentIndex)
//        
//        if currentIndex == index {
//            return
//        }
//        
//        if currentIndex < index {
//            while(currentIndex < index) {
//                
//            }
//        }
        
        
        let startingViewController: SessionContentViewController =
        viewControllerAtIndex(index)!
        
        var direction = UIPageViewControllerNavigationDirection.Forward
        if (self.currentIndex > index) {
            direction = UIPageViewControllerNavigationDirection.Reverse
        }


        let viewControllers: NSArray = [startingViewController]
        pageController!.setViewControllers(viewControllers as [AnyObject],
            direction: direction,
            animated: true,
            completion: nil)
        
        self.addChildViewController(pageController!)
        self.view.addSubview(self.pageController!.view)
        
        var pageViewRect = self.view.bounds
        pageController!.view.frame = pageViewRect
        pageController!.didMoveToParentViewController(self)
        
        currentIndex = index

    }
    
    

    /**
        This function creates calls the function to create the page view controller as long as there are active sessions.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        if sessions.count != 0 {
            self.organizeChildren()
        }   
    }

    /**
        This function is called when a memory warning is received.
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

