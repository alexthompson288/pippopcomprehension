//
//  QuestionViewController.swift
//  pippopcomprehension
//
//  Created by Alex Thompson on 07/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit

class QuestionViewController: UIViewController {

    var qData = NSArray()
    var index = 0 { didSet { checkIfEnd() }}
    var totalQ = 0
    var score = 0 {didSet { updateUI() }}
    var correctAnswer = ""
    var answers = [String]()
    
    @IBOutlet weak var QuestionLabel: UILabel!
    
    @IBOutlet weak var QuestionImage: UIImageView!
    
    @IBOutlet weak var Answer1Label: UIButton!
    
    @IBOutlet weak var Answer2Label: UIButton!
    
    @IBOutlet weak var Answer3Label: UIButton!
    
    @IBOutlet weak var EndQuizLabel: UIButton!
    
    @IBOutlet weak var ScoreLabel: UILabel!
    
    override func viewDidLoad() {
        self.EndQuizLabel.hidden = true
        totalQ = self.qData.count
        updateUI()
        println("Quesiton VC loaded")
        println("Question data is \(qData)")
        setQuestion()
    }
    
    func updateUI(){
        self.ScoreLabel.text = "Score: \(self.score)/\(self.totalQ)"
    }
    
    func endQuiz(){
        self.Answer1Label.hidden = true
        self.Answer2Label.hidden = true
        self.Answer3Label.hidden = true
        self.QuestionImage.hidden = true
        self.EndQuizLabel.hidden = false
    }
    
    func checkIfEnd() -> Bool{
        if self.index  == self.totalQ {
            println("It is end because index: \(self.index + 1) and total: \(self.totalQ)")
            endQuiz()
            return true
        } else {
            return false
        }
    }
    
    func setQuestion(){
        var isEnd = checkIfEnd()
        if isEnd == false {
            println("Index is \(self.index)")
            var thisQuestion:NSDictionary = qData[index] as! NSDictionary
            println("This question data is \(thisQuestion)")
            var goodAnswer = thisQuestion["correct_answer"] as! String
            var badAnswer1 = thisQuestion["incorrect_answer_1"] as! String
            var badAnswer2 = thisQuestion["incorrect_answer_2"] as! String
            self.answers = []
            self.answers.append(goodAnswer)
            self.answers.append(badAnswer1)
            self.answers.append(badAnswer2)
            var newAnswers = Utility.shuffle(self.answers)
            self.correctAnswer = goodAnswer
            self.Answer1Label.setTitle(newAnswers[0], forState: .Normal)
            self.Answer2Label.setTitle(newAnswers[1], forState: .Normal)
            self.Answer3Label.setTitle(newAnswers[2], forState: .Normal)
        } else {
            println("It is the end!")
        }
    }
    
    
    @IBAction func Answer1Button(sender: AnyObject) {
        println("Answer 1 chosen")
        if Answer1Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
        }
        self.index++
        setQuestion()
        
    }
    
    @IBAction func Answer2Button(sender: AnyObject) {
        println("Answer 2 chosen")
        if Answer2Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
        }
        self.index++
        setQuestion()
    }
    
    @IBAction func Answer3Button(sender: AnyObject) {
        println("Answer 3 chosen")
        if Answer3Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
        }
        self.index++
        setQuestion()
    }
    
    @IBAction func EndQuiz(sender: AnyObject) {
        println("Ending quiz")

    }
    
    
}
