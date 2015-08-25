//
//  PerformanceViewController.swift
//  pippopcomprehension
//
//  Created by Alex Thompson on 25/08/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class PerformanceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var userScore = Int()
    var totalScore = Int()
    var userAnswers = NSArray(){
        didSet{
            updateUI()
        }
    }
    var activityType = "Cms::Comprehension"
    var learnerId: Int!
    var access_token: String!
    var activityId: Int!

    @IBOutlet weak var UserScoreLabel: UILabel!
    
    @IBOutlet weak var MyTable: UITableView!
    
    func updateUI(){
        println("Updating UI")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        println("Number of sections...")
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("Number of row is \(userAnswers.count)")
        return userAnswers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:PerformanceCell = self.MyTable.dequeueReusableCellWithIdentifier("PerformanceCell") as! PerformanceCell
        cell.QuestionLabel.text = self.userAnswers[indexPath.row]["question"] as! String
        var correctAnswer = self.userAnswers[indexPath.row]["correct_answer"] as! String
        var userAnswer = self.userAnswers[indexPath.row]["user_answer"] as! String
        if correctAnswer == userAnswer {
            cell.UserAnswerLabel.text = "You got it right!"
            cell.AnswerStatusImage.image = UIImage(named: "tick")
        } else {
            cell.UserAnswerLabel.text = "You chose: \(userAnswer)"
            cell.AnswerStatusImage.image = UIImage(named: "cross")
        }
        
        return cell
    }
    
    
    override func viewDidLoad() {
        println("Number of items in array is \(userAnswers.count)")
        
        println("view loaded")
        self.MyTable.delegate = self
        self.MyTable.dataSource = self
        self.UserScoreLabel.text = "You scored \(userScore)/\(totalScore)"
        self.MyTable.reloadData()
        if let currentLearner = NSUserDefaults.standardUserDefaults().objectForKey("learnerID") as? Int {
            self.access_token = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as! String
            self.learnerId = currentLearner
            
            let data = NSJSONSerialization.dataWithJSONObject(userAnswers, options: nil, error: nil)
            let performanceData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            println("Details - access token: \(self.access_token). learner id: \(self.learnerId). activity type: \(activityType). activity_id: \(activityId). Performance data is \(performanceData!)")
            Utility.postActivityDataToServers(self.access_token, learner_id: self.learnerId, activity_id: self.activityId, activity_type: self.activityType, score: self.userScore, performance: performanceData!)
        }
        
    }

}
