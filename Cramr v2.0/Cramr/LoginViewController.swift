//
//  LoginViewController.swift
//  Cramr v2.0
//
//  Created by Roberto Alvarez on 1/31/15.
//  Copyright (c) 2015 Casa, Inc. All rights reserved.
//

import Foundation

struct currentUserInfo {
    static var userID = ""
    static var sessionID = ""
}
let notificationKey = "com.cramr.notificationKey"

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    
    var avplayer: AVPlayer = AVPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .lightGrayColor()
    }
    
    /* ---------THIS IMPLEMENTATION USES AVPLayer (also did MPMovie Player stashed) ------------- */
    override func viewDidAppear(animated: Bool) {
        let filepath = NSBundle.mainBundle().pathForResource("entrance", ofType: "mp4")
        let fileURL = NSURL.fileURLWithPath(filepath!)
        self.avplayer = AVPlayer.playerWithURL(fileURL) as AVPlayer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd", name: notificationKey, object: self.avplayer)
        var height = UIScreen.mainScreen().bounds.size.height
        var width = height*1.77

        var layer = AVPlayerLayer(player: self.avplayer)
        self.avplayer.actionAtItemEnd = AVPlayerActionAtItemEnd(rawValue: 2)!
        layer.frame = CGRectMake(0,0,width, height)
        self.view.layer.addSublayer(layer)
        self.avplayer.play()
        // Do any additional setup for FB
        nameLabel.text = ""
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        self.view.bringSubviewToFront(self.fbLoginView)
    }
    
    /* Currently notification at end of video not working, but in either case, every discusion online states that there is no way to re-start video after end without hicups (with AVPlayer) */
    func playerItemDidReachEnd(notif: NSNotification){
        var p:  AVPlayer = notif.object as AVPlayer
        p.seekToTime(kCMTimeZero)
        p.play()
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toMaster" {
        }
    }
    
    func setCurrUser() {
        if (FBSession.activeSession().isOpen){
            var friendsRequest : FBRequest = FBRequest.requestForMe()
            friendsRequest.startWithCompletionHandler{(connection:FBRequestConnection!, result:AnyObject!,error:NSError!) -> Void in
                var resultdict = result as NSDictionary
                currentUserInfo.userID = resultdict["id"] as String
            }
        }
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        NSLog("User Logged In")
//        setCurrUser()
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        NSLog("User: \(user)")
        NSLog("User ID: \(user.objectID)")
        NSLog("User Name: \(user.name)")
        var userEmail = user.objectForKey("email") as String
        NSLog("User Email: \(userEmail)")
        nameLabel.text = user.name
        
        //        setCurrUser()
        
        var query = PFUser.query();
        query.whereKey("userID", containsString: user.objectID)
        query.findObjectsInBackgroundWithBlock {
            (users: [AnyObject]!, error: NSError!) -> Void in
            if users.count == 0 {
                var parse_user = PFUser()
                parse_user.username = user.name
                parse_user.password = ""
                parse_user.email = userEmail
                parse_user["userID"] = user.objectID
                
                var imageData : UIImage!
                let url: NSURL? = NSURL(string: "https://graph.facebook.com/\(user.objectID)/picture")
                if let data = NSData(contentsOfURL: url!) {
                    imageData = UIImage(data: data)
                }
                let image = UIImagePNGRepresentation(imageData)
                let imageFile = PFFile(name:"profilepic.png", data:image)
                var userPhoto = PFObject(className:"UserPhoto")
                userPhoto["imageName"] = "Profile pic of \(user.objectID)"
                userPhoto["imageFile"] = imageFile
                parse_user["image"] = userPhoto
                
                parse_user.signUp()
            }
        }
    
        currentUserInfo.userID = user.objectID
        self.performSegueWithIdentifier("toMaster", sender: self)
        
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        NSLog("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        NSLog("Error: \(handleError.localizedDescription)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}