
/* ----------- Functions that are used throught the entire project  ----------- */

import Foundation
import SystemConfiguration

/* ----------- Color Variations ----------- */
/*
var cramrBlue = UIColorFromRGB(UInt(9550335)) //Original Cramr Blue
var cramrBlue = UIColorFromRGB(UInt(10972979)) //Light Brown
var cramrBlue = UIColorFromRGB(UInt(6242857)) //Dark Brown
var cramrBlue = UIColorFromRGB(UInt(6291576)) //Dark Purple
var cramrBlue = UIColorFromRGB(UInt(9109677)) //Light Purple
var cramrBlue = UIColorFromRGB(UInt(543419)) //Dark Blue
var cramrBlue = UIColorFromRGB(UInt(24079)) //Green
*/

var originalCramrBlue = UIColorFromRGB(UInt(9550335)) //Original Cramr Blue
var cramrBlue = UIColorFromRGB(UInt(3363506))

var navigationBarHeight = 64


/**
    Given a String splits on ':' and returns first element. That is given s1 of the form "CS 228: Probabilistic Graphical Models" returns "CS 228"
    :param: item - the string to parse at symbol ":"
*/
func getCourseID(item: String) -> String {
    var arr = split(item) {$0 == ":"}
    return arr[0]
}

/**
    Given a string of the form "Marco Alban Hidalgo" returns "Marco A."
    :param: longName
*/
func getShortName(longName: String) -> String{
    var name = ""
    if longName != "" {
        var arr = split(longName) {$0 == " "}
        name = arr[0]
        if arr.count > 1 {
            var firstCharLastName = Array(arr[arr.count-1])[0]
            name += " " + [firstCharLastName] + ""
        }
    }
    return name
}

/**
    Given a String splits on ':' and returns second element. That is, given s1 of the form "CS 228: Probabilistic Graphical Models" returns "Probabilistic Graphical Models"
    :param: item - the string to parse at symbol ":"
*/
func getCourseName(item: String) -> String {
    var arr = split(item) {$0 == ":"}
    return arr[1]
}

/**
    Takes a colour as an unsigned integer and returns a UIColor
*/
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

/**
    Returns dictionary with all the passed in key, value pairs
*/
func convertToSessionDict(sessionID: String, description: String, location: String, courseName: String, latitude: String, longitude: String ) -> [String: String] {
    return ["sessionID": sessionID, "description": description, "location": location, "course": courseName, "latitude": latitude, "longitude": longitude]
}

/**
    Checks to see if sessions are equal
    :param: first  - dictionary, the first session
    :param: second - dictionary, the other session
*/
func areEqualSessions(first: [String: String], second: [String: String]) -> Bool {
    return first["description"] == second["description"] && first["sessionID"] == second["sessionID"] && first["course"] == second["course"]
}

/**
    Adds a little blue marker on the top left of the mapView. If the button is pressed, the mapView refocuses on the actual location.
    :param: view        - mapView where button will be overlayed
    :param: controller  - the viewController that has the mapView
*/
func addMapButton(view: UIView, controller: UIViewController) {
    var cx = CGFloat(5)
    var cy = CGFloat(105)
    
    var myLocationButton = UIButton()
    myLocationButton.setImage(UIImage(named: "blue_3d_marker"), forState: UIControlState.Normal)
    var buttonRect = CGRect()
    buttonRect.size.height = 40.0
    buttonRect.size.width = 40.0
    buttonRect.origin.x = cx
    buttonRect.origin.y = cy
    
    myLocationButton.frame = buttonRect
    myLocationButton.tintColor = cramrBlue
    myLocationButton.layer.cornerRadius = myLocationButton.frame.size.width / 2
    myLocationButton.addTarget(controller, action: "tappedLocationButton:", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(myLocationButton)
}

/**
    Checks to see if the application is connected to the internet, if not it pops an alert with the specified message informing the user.
    :param: controller  - the viewController where the alert will be shown
    :param: app         - the AppDelegate
    :param: message     - the message that will be displayed in the alert, default to ""You are not connected to a network."
*/
func checkForNetwork(controller: UIViewController, app: AppDelegate, message: String = "You are not connected to a network.") {
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
        dispatch_async(dispatch_get_main_queue()) {
            if !app.isConnectedToNetwork() {
                var alert = UIAlertController(title: "No Internet Connection", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                controller.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}

/**
    Adds a blur background to the array of subviews 
    :param: superView   - the UIView that contains the array of subViews
    :param: subView     - array of views where blur will be set
*/
func addBlur(superView : UIView, subViews : [UIView]) {
    
    var frame = CGRect()
    var center = CGPoint(x: 0.0, y: 0.0)
    var width = CGFloat(0.0)
    var height = CGFloat(0.0)
    
    for var i = 0; i < subViews.count; i++ {
        
        width = subViews[i].frame.width
        var temp = CGFloat(subViews[i].frame.height)
        height += temp
        
        center.x += subViews[i].center.x
        center.y += subViews[i].center.y
    }
    
    frame = CGRectMake(0, 0, width, height)
    
    center.x = center.x / CGFloat(subViews.count)
    center.y = center.y / CGFloat(subViews.count)
    
    // Blur Effect
    var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
    var blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = frame
    blurEffectView.center = center
//    blurEffectView.layer.borderWidth = 1.0
//    blurEffectView.layer.borderColor = cramrBlue.CGColor

    
    superView.addSubview(blurEffectView)
    
    for subView in subViews {
        superView.bringSubviewToFront(subView)
    }
}

extension UIView {
    
    func getImage() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}