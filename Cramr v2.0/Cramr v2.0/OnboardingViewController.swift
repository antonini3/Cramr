//
//  OnboardingViewController.swift
//  Cramr v2.0
//
//  Created by Anton Apostolatos on 3/10/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import Foundation

import UIKit

/**
    This class is used during a user's first visit to the app. It takes them through an onboarding walkthrough on how to use the app.
*/
class OnboardingViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let pageTitles = ["Welcome to Cramr!", "Add Your Courses", "Browse and Join Study Sessions", "Or Create Your Own!", "Tap Below to Get Started"]
    let subTitles = ["The app that lets you make study groups on the fly!", "", "", "", ""]
    var images = ["","AddCourseCS106A","BrowseSessionsCS106A", "CreateSession221", ""]
    var count = 0
    
    var pageViewController : UIPageViewController!
    
    /**
        This function is used for debugging purposes.
    
        :param:  sender  the sender of the action
    */
    @IBAction func swipeLeft(sender: AnyObject) {
        println("Swipe left")
    }
    
    /**
        This function is used for swiping through the view controllers in the page view.
    
        :param:  sender  the sender of the action
    */
    @IBAction func swiped(sender: AnyObject) {
        
        self.pageViewController.view.removeFromSuperview()
        self.pageViewController.removeFromParentViewController()
        reset()
    }
    
    /**
        This function is used to have the navigation and status bars display white text instead of the black default.
    */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /**
        This function resets the page view controller for the onboarding walkthrough.
    */
    func reset() {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.navigationBar.translucent = false
        
        self.view.backgroundColor = cramrBlue
        
        /* Getting the page View controller */
        pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("OnboardingPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        /* We are substracting 30 because we have a start again button whose height is 30*/
        
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    /**
        This function starts the onboarding walkthrough.
    */
    @IBAction func start(sender: AnyObject) {
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    /**
        This function initializes the onboarding page view controller by calling the reset function.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
    }
    
    /**
        This function is used for debugging purposes when a memory warning is received.
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        This function returns the onboarding content view controller for the bordering onboarding content view controller after the one the user is looking at.
        
        :param:  pageViewController  the entire page view controller
        :param:  viewControllerBeforeViewController  the view controller the user is looking at
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! OnboardingContentViewController).pageIndex!
        index++
        if(index >= self.images.count){
            return nil
        }
        return self.viewControllerAtIndex(index)
        
    }
    
    /**
        This function returns the onboarding content view controller for the bordering onboarding content view 
        controller before the one the user is looking at.
        
        :param:  pageViewController  the entire page view controller
        :param:  viewControllerBeforeViewController  the view controller the user is looking at
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! OnboardingContentViewController).pageIndex!
        if(index <= 0){
            return nil
        }
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
    /**
        This function returns the onboarding content view controller for the chosen index of the page view controller.
        
        :param:  index  index of the view controller being returned
    */
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return nil
        }
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("OnboardingContentViewController") as! OnboardingContentViewController
        
        pageContentViewController.imageName = self.images[index]
        pageContentViewController.titleText = self.pageTitles[index]
        pageContentViewController.subtitleText = self.subTitles[index]
        pageContentViewController.pageIndex = index
        return pageContentViewController
    }
    
    /**
        This function is used for the onscreen indicator of what page of the walkthrough the user is on.
    */
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
    }
    
    /**
        This function is used for the onscreen indicator of what page of the walkthrough the user is on.
    */
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}