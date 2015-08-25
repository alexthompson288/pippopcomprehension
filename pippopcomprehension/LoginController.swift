//
//  LoginController.swift
//  pippopcomprehension
//
//  Created by Alex Thompson on 04/08/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

//
//  LoginController.swift
//  pippopactivities
//
//  Created by Alex Thompson on 31/05/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

var learnerNames = [String]()
var learnerIDs = [Int]()
var connected:Bool!

class LoginController:UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ParentQuestionLabel: UILabel!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var LoginFieldsView: UIView!
    
    @IBOutlet weak var LoginButtonLabel: UIButton!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ParentGateView: UIView!
   
    
    @IBAction func ParentTriangleButton(sender: AnyObject) {
        if self.shape == "triangle"{
            println("Correct")
            self.parentPass = true
            self.ParentGateView.hidden = true
            self.continueUserFlow()
        } else {
            println("Wrong")
            self.ParentGateView.hidden = true
        }
    }
    
    @IBAction func ParentCircleButton(sender: AnyObject) {
        if self.shape == "circle"{
            println("Correct")
            self.parentPass = true
            self.ParentGateView.hidden = true
            self.continueUserFlow()
        } else {
            println("Wrong")
            self.ParentGateView.hidden = true
        }
    }
    
    @IBAction func ParentSquareButton(sender: AnyObject) {
        if self.shape == "square"{
            println("Correct")
            self.parentPass = true
            self.ParentGateView.hidden = true
            self.continueUserFlow()
        } else {
            println("Wrong")
            self.ParentGateView.hidden = true
        }
    }
   
    
    func continueUserFlow(){
        println("User flow is \(self.userFlow)")
        if self.userFlow == "login" {
            println("About to run first login function")
            FirstLoginUserFunction()
        } else if self.userFlow == "register" {
            println("About to run first register function")
        } else if self.userFlow == "forgottenpassword" {
            println("About to run first forgotten password function")
            showForgottenPassword()
        } else if self.userFlow == "terms" {
            showTerms()
        }
    }
    
    var userFlow = "login"
    var parentPass = false
    var shapes = ["circle","square","triangle"]
    var shape = ""
    var visible:CGFloat = 1.0
    var invisible:CGFloat = 0.0
    var moviePlayer = MPMoviePlayerController()
    
    var loginScreen = true{
        didSet{
            updateUI()
        }
    }
    
    var menuScreen = false{
        didSet{
            updateUI()
        }
    }
    
    var token:String = ""
    var savedEmail:String?
    
    override func viewDidLoad() {
        self.ParentGateView.hidden = true
        println("Login view loaded...")
//        self.LoginFieldsView.layer.borderWidth = 3.0
//        self.LoginFieldsView.layer.borderColor = UIColor.redColor().CGColor
//        self.LoginFieldsView.layer.cornerRadius = 5.0
        playCorrectVideo()
        self.ErrorLabel.hidden = true
        self.PasswordField.delegate = self
        self.EmailField.delegate = self
        self.loginScreen = true
        println("Login controller")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide", name: UIKeyboardDidHideNotification, object: nil)
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideParentGate")
        view.addGestureRecognizer(tap)
    }
    
    func hideParentGate(){
        println("Tap...")
        self.ParentGateView.hidden = true
    }
    
    func keyboardDidShow(){
        self.LoginButtonLabel.hidden = true
    }
    
    func keyboardDidHide(){
        self.LoginButtonLabel.hidden = false
    }
    
    
    func checkAccessExpiration(){
        var val = NSUserDefaults.standardUserDefaults().objectForKey("access_expiration") as? String
        if let access = val {
            if access != "" {
                println("Access value is \(access)")
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy:MM:dd"
                var date = dateFormatter.dateFromString(access)
                println("Converted date is...\(date)")
                var todaysDate:NSDate = NSDate()
                println("Todays date is \(todaysDate)")
                if(date!.isGreaterThanDate(todaysDate))
                {
                    println("Let them in, try to get a new token and perform segue")
                    dispatch_async(dispatch_get_main_queue())
                        {
                            var vc: ComprehensionsIndexController = self.storyboard?.instantiateViewControllerWithIdentifier("ComprehensionsIndexID") as! ComprehensionsIndexController
                            self.presentViewController(vc, animated: true, completion: nil)
                    }
                } else {
                    self.ErrorLabel.hidden = false
                    println("Block them out")
                    self.ErrorLabel.text = "You need to login again"
                }
            }
        }
        
    }
    
    
    func playCorrectVideo(){
        var device = UIDevice.currentDevice().userInterfaceIdiom
        var urlpath: NSURL!
        if device == .Pad {
            println("Using iPad")
            urlpath = NSBundle.mainBundle().URLForResource("iPadLoginVideo", withExtension: "mp4")
        } else  {
            println("Using iPhone")
            urlpath = NSBundle.mainBundle().URLForResource("iPhoneLoginVideo", withExtension: "mp4")
        }
        
        println("url path is \(urlpath)")
//        self.moviePlayer = MPMoviePlayerController(contentURL: urlpath!)
//        self.moviePlayer.shouldAutoplay = true
//        self.moviePlayer.setFullscreen(false, animated: true)
//        self.moviePlayer.controlStyle = MPMovieControlStyle.None
//        self.moviePlayer.scalingMode = MPMovieScalingMode.AspectFit
//        self.moviePlayer.repeatMode = MPMovieRepeatMode.One
//        self.moviePlayer.view.frame = self.view.bounds
//        self.view.addSubview(self.moviePlayer.view)
//        self.view.sendSubviewToBack(moviePlayer.view)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.ErrorLabel.hidden = true
        self.ActivityIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(animated: Bool) {
        checkAccessExpiration()
        self.moviePlayer.play()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.moviePlayer.stop()
    }
    
    func updateUI(){
        
    }
    
    @IBAction func TermsButton(sender: AnyObject) {
        self.userFlow = "terms"
        println("Changing user flow to terms: \(self.userFlow)")
        showParentGate()
    }
    
    @IBAction func ForgottenPasswordButton(sender: AnyObject) {
        self.userFlow = "forgottenpassword"
        self.showParentGate()
    }
    @IBAction func LoginButton(sender: AnyObject) {
        self.userFlow = "login"
        self.FirstLoginUserFunction()
    }

    
    func FirstLoginUserFunction(){
        if self.EmailField.text == "" {
            self.ErrorLabel.hidden = false
            self.ErrorLabel.text = "Fill in email"
        } else if self.PasswordField.text == ""{
            self.ErrorLabel.hidden = false
            self.ErrorLabel.text = "Fill in password"
        } else {
            LogUserInRemote(self.EmailField.text, password: self.PasswordField.text)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("Pressed return")
        textField.resignFirstResponder()
        self.view.endEditing(true)
        if self.loginScreen == true {
            self.userFlow = "login"
            showParentGate()
        } else {
            self.userFlow = "register"
            showParentGate()
        }
        
        return true
    }
    
    func logUserIn(){
        var email = ""
        var password = ""
        email = NSUserDefaults.standardUserDefaults().objectForKey("email") as! String
        password = NSUserDefaults.standardUserDefaults().objectForKey("password") as! String
        println("Saved email is \(email) and password is \(password)")
        if email == ""{
            var thisEmail = self.EmailField.text
            var thisPassword = self.PasswordField.text
            println("Remote login with \(thisEmail) and \(thisPassword)")
            LogUserInRemote(thisEmail, password: thisPassword)
        }
    }
    
    
    func LogUserInRemote(email:String, password:String){
        connected = Reachability.isConnectedToNetwork()
        if connected == true {
            self.ActivityIndicator.startAnimating()
            let url = NSURL(string: Constants.TokenUrl)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.HTTPBody = "{\n    \"email\": \"\(email)\",\"password\": \"\(password)\"\n}".dataUsingEncoding(NSUTF8StringEncoding);
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
                
                if error != nil {
                    // Handle error...
                    self.ActivityIndicator.stopAnimating()
                    return
                }
                var responseObject:NSDictionary?
                responseObject = Utility.dataToJSON(data)
                if let jsonDict = responseObject {
                    var errors:Array<String>?
                    errors = jsonDict["errors"] as? Array
                    if let thisError = errors {
                        dispatch_async(dispatch_get_main_queue()){
                            self.ErrorLabel.hidden = false
                            println("Errors are \(thisError[0])")
                            self.ErrorLabel.text = thisError[0]
                            self.ActivityIndicator.stopAnimating()
                            self.ActivityIndicator.hidden = true
                            return
                        }
                    } else {
                        var access = jsonDict["access_token"] as! NSString
                        var expires = jsonDict["token_expiration_date"] as! NSString
                        println("Access expires at \(expires)...")
                        var learners: NSArray = jsonDict["learners"] as! NSArray
                        if learners.count == 0 {
                            println("Teacher with no learners - no login")
                            dispatch_async(dispatch_get_main_queue()){
                                self.ErrorLabel.hidden = false
                                self.ErrorLabel.text = "Unable to login - no learners"
                                self.ActivityIndicator.stopAnimating()
                            }
                            
                        } else {
                            NSUserDefaults.standardUserDefaults().setObject(email, forKey: "email")
                            NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
                            NSUserDefaults.standardUserDefaults().setObject(access, forKey: "access_token")
                            NSUserDefaults.standardUserDefaults().setObject(expires, forKey: "access_expiration")
                            self.token = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as! String
                            println("User email is \(email) and password is \(password)")
                            Utility.saveJSONWithArchiver(jsonDict, savedName: "userData.plist")
                            println("JSON saved locally.")
                            if self.token != ""{
                                self.ErrorLabel.hidden = false
                                self.ErrorLabel.text = "Logged in"
                            }
                            self.ActivityIndicator.stopAnimating()
                            println("About to present menu VC...")
                            var vc: ComprehensionsIndexController = self.storyboard?.instantiateViewControllerWithIdentifier("ComprehensionsIndexID") as! ComprehensionsIndexController
                            self.presentViewController(vc, animated: true, completion: nil)
                        }
                    }
                }
                else{
                    println("problem in JSON")
                    self.ActivityIndicator.stopAnimating()
                }
            }
            task.resume()
        } else {
            self.ErrorLabel.text = "No internet..."
        }
    }
    
    func showParentGate() {
        self.ParentGateView.hidden = false
        var newShapes = Utility.shuffle(self.shapes)
        self.shape = newShapes[0]
        self.ParentQuestionLabel.text = "Touch the \(newShapes[0])"
    }
    
    func showForgottenPassword(){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.pippoplearning.com/accounts/password/new")!)
    }
    
    func showTerms(){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.pippoplearning.com/termsandprivacy.pdf")!)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
}

extension NSDate
{
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
}



