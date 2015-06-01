
import Foundation

let notificationKey = "com.cramr.notificationKey"

/**
    View conroller for logging in. Conforms to FBLoginViewDelegate. It presents and FBLoginView and handles signing in the user through parse.

    - fbLoginView:              developed by Facebook, facebook login view button
    - avplayer:                 the video player that handles playing the login intro video
    - appDelegate:              AppDelegate
    - isFirstRun:               Bool true if it is the first time opening the app (for onboarding)
*/

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet weak var fbLoginView = FBLoginView();
    
    var avplayer: AVPlayer = AVPlayer()
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var isFirstRun: Bool = false
    
    /**
        Initializes fbLoginView, reads the facebook permissions, and starts the video player
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fbLoginView!.delegate = self
        self.fbLoginView!.readPermissions = ["public_profile", "email", "user_friends"]
        
        // Get the intro video frome the bundle and instantiate the player
        let filepath = NSBundle.mainBundle().pathForResource("cramr_intro_video", ofType: "mov")
        let fileURL = NSURL.fileURLWithPath(filepath!)
        self.avplayer = AVPlayer.playerWithURL(fileURL) as! AVPlayer
        
        //Set notification when player reaches the end of the vidoe
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd", name: notificationKey, object: self.avplayer)
        self.avplayer.actionAtItemEnd = AVPlayerActionAtItemEnd(rawValue: 2)!
        var height = UIScreen.mainScreen().bounds.size.height + 4.0
        var width = UIScreen.mainScreen().bounds.width
        
        //Instantiate the layer and set appropriate size
        var layer = AVPlayerLayer(player: self.avplayer)
        self.avplayer.actionAtItemEnd = AVPlayerActionAtItemEnd(rawValue: 2)!
        var rect = CGRectMake(50, 200, width, height)
        rect.origin.x = (self.view.frame.width - width) / 2.0
        rect.origin.y = self.view.frame.height - height + 3.0
        layer.frame = rect
        
        self.view.layer.addSublayer(layer)
        self.avplayer.play()
        self.view.bringSubviewToFront(self.fbLoginView!)
    }
    
    /**
        Resets player to video start when the nofification is received
        :param: notif NSNotification
    */
    func playerItemDidReachEnd(notif: NSNotification){
        var p:  AVPlayer = notif.object as! AVPlayer
        p.seekToTime(kCMTimeZero)
        p.play()
    }
    
    
    /**
        If a Facebook session is open, cached the user id in local storage.
    */
    func setCurrUser() {
        if (FBSession.activeSession().isOpen){
            var friendsRequest : FBRequest = FBRequest.requestForMe()
            friendsRequest.startWithCompletionHandler{(connection:FBRequestConnection!, result:AnyObject!,error:NSError!) -> Void in
                var resultdict = result as! NSDictionary
                self.appDelegate.localData.setUserID(resultdict["id"] as! String)
            }
        }
    }
    
    
    /* ---------------------------- Facebook Delegate Methods ---------------------------- */
    
    /**
        Satisfies FBLoginViewDelegate. These are the actions performed when the user is logged in, if it is the user's
        first time loging in show onbording, else go to view showing courses.
        :param: loginView FBLoginView!
    */
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        if self.isFirstRun {
            self.appDelegate.go_to_onboarding(animated: false)
        } else {
            self.performSegueWithIdentifier("toMaster", sender: self)
        }
    }
    
    /**
        Satisfies FBLoginViewDelegate. Called when the user's information was fetched.
        :param: loginView FBLoginView!
        :param: user FBGraphUser
    */
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        var userEmail = user.objectForKey("email") as! String
        
        // Query parse for user with userid, and fetch data in background, if the user
        // is not already in parse, sign him/her up with parse and cached the userid and username
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
                let url: NSURL? = NSURL(string: "https://graph.facebook.com/\(user.objectID)/picture?type=large")
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
        
        appDelegate.localData.setUserID(user.objectID)
        appDelegate.localData.setUserName(user.name)
        appDelegate.DBAccess?.getUserPictureURL(user.objectID, callback: setImageURLCallback)
    }
    
    func setImageURLCallback(imageUrl: String) {
        appDelegate.localData.setImageURL(imageUrl)
    }
    
    /**
        Satisfies FBLoginViewDelegate. Called when the user's information was fetched.
        :param: loginView FBLoginView!
        :param: user FBGraphUser
    */
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        NSLog("User Logged Out")
    }
    
    /**
        Satisfies FBLoginViewDelegate. Called when fb login had an error
        :param: loginView FBLoginView!
        :param: handleError NSError
    */
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        NSLog("Error: \(handleError.localizedDescription)")
    }
    
    
}