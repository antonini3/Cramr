//
//  OnboardingContentViewController.swift
//  Cramr v2.0
//
//  Created by Anton Apostolatos on 3/10/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import Foundation

/**
    This class regulates the information that is shown at each step of the onboarding walkthrough.
*/
class OnboardingContentViewController: UIViewController {
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var goToLoginButton: UIButton!
    
    var avplayer: AVPlayer = AVPlayer()
    
    @IBAction func goToLogin(sender: AnyObject) {
        appDelegate.go_to_masterview(animated: true)
    }

    @IBOutlet weak var subtitle: UILabel!
    
    @IBOutlet weak var heading: UILabel!
    
    var pageIndex: Int?
    var titleText : String!
    var subtitleText : String!
    var imageName : String!
    
    /**
        This function ensures that the walkthrough video begins playing as soon as the user gets to the view.
    */
    override func viewDidAppear(animated: Bool) {
        if self.imageName != "" {
            self.avplayer.play()
        }
    }
    
    /**
        This function is currently not in use but it will be used to display the user's profile picture on the final page of the onboarding walkthrough.
    
        :param:  pictDict  Dictionary maps usernames to images
    */
    func displayProfilePicture(pictDict : [String: UIImage]) {
        for im in pictDict.values {
            var imView = UIImageView(image: im)
            
            var rect = imView.frame
            rect.size.height = 100.0
            rect.size.width = 100.0
            rect.origin.x = (self.view.frame.width - rect.size.width) / CGFloat(2.0)
            rect.origin.y = CGFloat(170 + 10)
            
            imView.frame = rect
            imView.layer.cornerRadius = imView.frame.size.width / 2
            imView.clipsToBounds = true
            
            imView.layer.borderWidth = 1.0
            imView.layer.borderColor = cramrBlue.CGColor
            
            self.view.addSubview(imView)
        }
    }
    
    /**
        Set parameters of the navigation bar, background, and other pieces of text, before adding the video.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.goToLoginButton.addTarget(self, action: "goToLogin:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.backgroundColor = cramrBlue
        self.heading.text = self.titleText
        self.subtitle.text = self.subtitleText
        self.heading.alpha = 1.0
        self.goToLoginButton.hidden = self.pageIndex != 4
        
        if self.imageName != "" {
            self.addVideo()
        }
    }
    
    /**
        This function uses an AVPlaver to add the video to the page.
    
        The video does not begin playing until the view appears (see viewDidAppear above)
    */
    func addVideo() {
        let filepath = NSBundle.mainBundle().pathForResource(self.imageName, ofType: "mov")
        let fileURL = NSURL.fileURLWithPath(filepath!)
        self.avplayer = AVPlayer.playerWithURL(fileURL)as! AVPlayer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd", name: notificationKey, object: self.avplayer)
        
        var height = UIScreen.mainScreen().bounds.size.height / 1.5
        var width = height / 1.778
        
        var layer = AVPlayerLayer(player: self.avplayer)
        self.avplayer.actionAtItemEnd = AVPlayerActionAtItemEnd(rawValue: 2)!
        var rect = CGRectMake(50, 200, width, height)
        rect.origin.x = (self.view.frame.width - width) / 2.0
        rect.origin.y = self.view.frame.height - height - 40
        layer.frame = rect
        
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 1.0
        
        self.view.layer.addSublayer(layer)

    }
}
