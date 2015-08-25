//
//  SettingsController.swift
//  pippopcomprehension
//
//  Created by Alex Thompson on 25/08/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UIViewController {
    
    var learners = []
    var learnerName = String()
    var access_token = String()
    var learner_id = Int()
    
    override func viewDidLoad() {
        self.access_token = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as! String
        if let currentLearner = NSUserDefaults.standardUserDefaults().objectForKey("learnerID") as? Int {
            self.learner_id = currentLearner
        }
    }
    
    @IBAction func UpdateData(sender: AnyObject) {
        var url = Constants.apiUrl
        println("Getting JSON FROM SERVER FOR BOOKS")
        getJSON(url, token: self.access_token, learner_id: self.learner_id)
    }
    
    func updateUI(){
        self.LearnerNameLabel.text = learnerName
    }
    
    @IBOutlet weak var LearnerNameLabel: UILabel!
    
    @IBAction func LogoutButton(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("password")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("access_token")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("learnerID")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("learnerName")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("premium_access")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("access_expiration")
        
        var vc: LoginController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginControllerID") as! LoginController
        presentViewController(vc, animated: true, completion: nil)

    }
    
    @IBAction func ChangeLearnerButton(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Learner", preferredStyle: .ActionSheet)
        optionMenu.popoverPresentationController?.sourceView = sender as! UIView
        
        for learner in learners {
            // 2
            var name = learner["name"] as! String
            var id = learner["id"] as! Int
            var premium_access = learner["premium_access"] as! Bool
            let chooseAction = UIAlertAction(title: "\(name)", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                println("New learner chosen: \(name)")
                NSUserDefaults.standardUserDefaults().setObject(name, forKey: "learnerName")
                NSUserDefaults.standardUserDefaults().setObject(id, forKey: "learnerID")
                NSUserDefaults.standardUserDefaults().setObject(premium_access, forKey: "premium_access")
                self.learnerName = name
                self.updateUI()
            })
            optionMenu.addAction(chooseAction)
        }
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

    @IBAction func BackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getJSON(api:String, token: String, learner_id: Int) {
        let url = NSURL(string: api)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        request.addValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            if error != nil {
                println("Error hitting API")
                return
            } else {
                println("Received data...\(data)")
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                var encodedJSON:NSDictionary = Utility.dataToJSON(data)
                Utility.saveJSONWithArchiver(encodedJSON, savedName: "data.plist")
                //                self.ActivitySpinner.stopAnimating()
                //                self.ActivitySpinner.hidden = true
            }
        }
        task.resume()
    }

}