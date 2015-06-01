
import Foundation
import UIKit

/**
    View conroller for a locked session. It shows the active session and allows the user to leave the session or to invite friends by sending a push notification.

    - friendPickerController:   developed by Facebook, viewController for choosing friends
    - appDelegate:              AppDelegate for access to server side database
    - leaveButton:              IBOutlet to leave button in view
    - desciptLabel:             Label for session description
    - locationLabel:            Label for location
    - lockedMapView:            GoogleMapServices mapView
    - currentMembersScrollView: Scroll view of profile pictures of current users in session
    - currentMembersDict:       Dictionary of currentmember is session <username> - > <userID>
    - session:                  Dicitonary with all the information of this session.
*/
class SessionLockedViewController: UIViewController, FBFriendPickerDelegate {
    
    var friendPickerController: FBFriendPickerViewController!
    
    var wasClosed = false
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var leaveButton: UIButton!

    @IBOutlet weak var desciptLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var lockedMapView: GMSMapView!
    
    @IBOutlet weak var currentMembersScrollView: UIScrollView!
    
    var currentMembersDict = [String : String]()
    
    var session: [String: String]! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var chatButton: UIButton!
    
    /**
        Call backback function to be called by appDelegate after we leave the session.
    */
    func leaveSessionCallback() {
        self.performSegueWithIdentifier("popToCourseView", sender: self)
    }
    
    /**
        IBAction to perform when the user clicks leaveSession button. If the app is connected to the network, we leave the Session and call leaveSessionCallback to segue to CoursesView. Else we alert the user that there is no internet connection.
    */
    @IBAction func leaveSession(sender: AnyObject) {
        self.wasClosed = true
        if appDelegate.isConnectedToNetwork() {
            appDelegate.leaveSessionAD(appDelegate.localData.getUserID(), sessionID: self.session["sessionID"]!, cb: self.leaveSessionCallback)
        } else {
             checkForNetwork(self, self.appDelegate)
        }
    }
    
    /**
        IBAction when the plus icon is pressed in the currentMembersScrollView. Fetches user friends and presents the friendPickerController. If the app is not connected to the internet, it pops an alert informing the user.
    */
    @IBAction func inviteFriends(sender: AnyObject) {
        if appDelegate.isConnectedToNetwork() {
            if(!FBSession.activeSession().isOpen){
                let permission = ["public_profile", "user_friends"]
                FBSession.openActiveSessionWithReadPermissions(
                    permission,
                    allowLoginUI: true,
                    completionHandler: { (session:FBSession!, state:FBSessionState, error:NSError!) in
                        
                        if(error != nil){
                            var alertView = UIAlertController(title: "Error Fetching Friends", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                            self.presentViewController(alertView, animated: true, completion: nil)
                        }
                        else if(session.isOpen){
                            self.inviteFriends(sender)
                        }
                    }
                    
                );
                return;
            }
            // If friendPicker is nil, initialize it and set title
            if(self.friendPickerController == nil){
                self.friendPickerController = FBFriendPickerViewController()
                self.friendPickerController.title = "Invite Friends"
                self.friendPickerController.delegate = self
            }
            
            self.friendPickerController.loadData()
            self.friendPickerController.clearSelection()
            
            //Set a new Frame to the friendPicker for aesthetics
            var newFrame = self.friendPickerController.view.bounds
            newFrame.size.height = newFrame.size.height + 1
            self.friendPickerController.tableView.frame = newFrame
            
            self.presentViewController(self.friendPickerController, animated: true, completion: nil)
        }
        // If there is not network, alert the user
        else {
             checkForNetwork(self, self.appDelegate)
        }
    }
    
    /**
        Conforms to FBFriendPickerDelegate. This function is called when the user clicks done in the friendPickerController, for each user selected we send a push notification in the background and alert the user that the invites were sent.
        :param: sender  - FBFriendPickerViewController
    */
    func facebookViewControllerDoneWasPressed(sender: AnyObject!) {
        var text = NSMutableString()
        let picker = sender as! FBFriendPickerViewController
        
        // For each friend that the user selected,  if the user is not already in the session,
        // send a push in background (form this view's perspective, handled by AppDelegate)
        for friend in picker.selection {
            var fdict = friend as! NSDictionary
            var id = fdict.objectForKey("id") as! String
            println(id)
            appDelegate.isUserInSessionAD(id, seshID: appDelegate.localData.getSessionID(), cb: appDelegate.sendPushCallback)
            
        }
        
        //Alert the user that the invites where sent, when the user dismisses alert, take us back
        //to SessionLocked
        if picker.selection.count > 0 {
            let alert = UIAlertController(title: "Invites Sent", message: "", preferredStyle: .Alert)
            let closeAction = UIAlertAction(title: "Dismiss", style: .Cancel) { action -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(closeAction)
            picker.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    /**
        Conforms to FBFriendPickerDelegate. When cancle is pressed, dismiss the pickerController
        :param: sender - FBFriendPickerViewController
    */
    func facebookViewControllerCancelWasPressed(sender: AnyObject!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
        Callback after appDelegate calls getSessionUsersPicturesAD. Once we have fetched the pictures of the users in the session this callback is called to set the scroll view to show the profile pictues.
        :param: pictDict    - Dictionary maps usernames to images
    */
    func displayCurrentUsers(pictDict : [String: UIImage]) {
        for view in self.currentMembersScrollView.subviews {
            view.removeFromSuperview()
        }
        self.currentMembersScrollView.backgroundColor = UIColor.clearColor()
        
        self.currentMembersScrollView.canCancelContentTouches = false
        self.currentMembersScrollView.indicatorStyle = UIScrollViewIndicatorStyle.White
        self.currentMembersScrollView.clipsToBounds = true
        self.currentMembersScrollView.scrollEnabled = true
        
        var cx = CGFloat(5)
        var cy = CGFloat(25)
        
        // for each image, set the image to be a circle with blue border and add it to 
        // currentMembersScrollView
        for im in pictDict.values {
            var imView = UIImageView(image: im)
            
            var rect = imView.frame
            rect.size.height = 50.0
            rect.size.width = 50.0
            rect.origin.x = cx
            rect.origin.y = cy
            
            imView.frame = rect
            imView.layer.cornerRadius = imView.frame.size.width / 2
            imView.clipsToBounds = true
            
            imView.layer.borderWidth = 1.0
            imView.layer.borderColor = cramrBlue.CGColor
            
            self.currentMembersScrollView.addSubview(imView)
            
            cx += imView.frame.size.width + 10
        }
        
        var lx = CGFloat(5)
        var ly = CGFloat(0)
        
        // for each user, add a label with the shortened name of the user to currentMembersScrollView
        for user in pictDict.keys {
            var label = UILabel()
            label.text = getShortName(currentMembersDict[user]!)
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont(name: label.font.fontName, size: 10)
            label.textColor = cramrBlue
            var labelRect = CGRect()
            labelRect.size.height = 25.0
            labelRect.size.width = 50.0
            labelRect.origin.x = lx
            labelRect.origin.y = ly
            
            label.frame = labelRect
            self.currentMembersScrollView.addSubview(label)
            
            lx += label.frame.size.width + 10
        }
        
        // Add the little plus button with action inviteFriends
        var addButton = UIButton() //.buttonWithType(UIButtonType.ContactAdd) as UIButton
        addButton.setImage(UIImage(named: "thin_blue_plus_icon"), forState: UIControlState.Normal)
        var buttonRect = CGRect()
        buttonRect.size.height = 50.0
        buttonRect.size.width = 50.0
        buttonRect.origin.x = cx
        buttonRect.origin.y = cy
        
        addButton.frame = buttonRect
        addButton.tintColor = cramrBlue
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
        addButton.addTarget(self, action: "inviteFriends:", forControlEvents: UIControlEvents.TouchUpInside)
        
        addButton.layer.borderWidth = 1.0
        addButton.layer.borderColor = cramrBlue.CGColor
        cx += addButton.frame.size.width + 10
        self.currentMembersScrollView.addSubview(addButton)
        
        self.currentMembersScrollView.contentSize = CGSizeMake(cx, self.currentMembersScrollView.bounds.size.height)
        
    }
    
    /**
        Callback for getSessionUsersAD from AppDelegate. After we get all the current members in the session, we pass a calback to getSessionUsersPicturesAD.
        :param: userNamesAndIds     -   dictionary of usernames and ids
    */
    func currentUsersCallback(userNamesAndIds: [(String, String)]) {
        
        var userIDs = [String]()
        for elem in userNamesAndIds {
            userIDs.append(elem.1)
            self.currentMembersDict[elem.1] = elem.0
        }
        
        appDelegate.getSessionUsersPicturesAD(userIDs, cb: displayCurrentUsers)
    }
    
    /**
        Sets up the GoogleMapServices mapView and adds a blue map marker
    */
    func setupMap() {
        var latitude: Double = (self.session["latitude"]! as NSString).doubleValue
        var longitude: Double = (self.session["longitude"]! as NSString).doubleValue
        
        var camera = GMSCameraPosition.cameraWithLatitude(latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees, zoom: 17.0)
        self.lockedMapView.camera = camera
        self.lockedMapView.myLocationEnabled = true
        
        var position = CLLocationCoordinate2DMake(latitude, longitude)
        var marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "blue_map_marker")
        marker.map = self.lockedMapView
        
        
        self.lockedMapView.layer.borderWidth = 1.0
        self.lockedMapView.layer.borderColor = cramrBlue.CGColor
        self.lockedMapView.padding = UIEdgeInsets(top: 150, left: 0, bottom: 70, right: 0)

    }
    
    /**
        Called on viewDidLoad or when user clicks refresh button on the top left corner. 
        * If the app is connected to the network, set the description and location label as well as set up the map and display the session users (fetched by appDelegate). 
        * If there is not conneciton, we alert the users.
    */
    func refreshView() {
        if appDelegate.isConnectedToNetwork() {
            if self.session != nil {
                var fullCourseName = (self.session["course"]! as String)
                desciptLabel.text = "  We're working on: " + (self.session["description"]! as String)
                locationLabel.text = "  We're working at: " + (self.session["location"]! as String)
                
                desciptLabel.numberOfLines = 0
                
                self.title = getCourseID(fullCourseName)
                setupMap()
                addBlur(self.view, [self.desciptLabel, self.locationLabel, self.currentMembersScrollView])
                appDelegate.getSessionUsersAD(session["sessionID"]!, cb: currentUsersCallback)
            }
        } else {
            checkForNetwork(self, self.appDelegate)
        }
    }
    
    
    func refreshThread() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            while (!self.wasClosed) {
                dispatch_async(dispatch_get_main_queue()) {
                    (UIApplication.sharedApplication().delegate as! AppDelegate).getSessionUsersAD(self.session["sessionID"]!, cb: self.currentUsersCallback)
                }
                sleep(5)
            }
            
        }
    }
    
    /**
        Set parameters of the navigation bar, add a refresh buttton to the navigationBar and call refreshView
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        self.view.backgroundColor = cramrBlue
        
//        var buttonFrame = self.chatButton.frame;
//        buttonFrame.size = CGSizeMake(50, 50)
//        self.chatButton.frame = buttonFrame;
        
        navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = cramrBlue
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.translucent = false

        
        self.refreshView()
        self.refreshThread()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshView")
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chatSegue" {
            (segue.destinationViewController as! MessagesViewController).backgroundImage = view.getImage()
            (segue.destinationViewController as! MessagesViewController).session = self.session
        }
    }
    
    @IBAction func popBackToSessionContent(segue:UIStoryboardSegue) {
        
    }
    
}
