//
//  QuestionViewController.swift
//  pippopcomprehension
//
//  Created by Alex Thompson on 07/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class QuestionViewController: UIViewController {

    var qData = NSArray()
    var index = 0 { didSet {
        updateUI()
        checkIfEnd()
        }
    }
    var totalQ = 0
    var score = 0 {didSet { updateUI() }}
    var correctAnswer = ""
    var answers = [String]()
    var thisQuestion = NSDictionary()
    var userAnswers = NSMutableArray()
    var activityId = Int()
    
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var QuestionImage: UIImageView!
    @IBOutlet weak var Answer1Label: UIButton!
    @IBOutlet weak var Answer2Label: UIButton!
    @IBOutlet weak var Answer3Label: UIButton!
    @IBOutlet weak var Answer4Label: UIButton!
    @IBOutlet weak var EndQuizLabel: UIButton!
    @IBOutlet weak var PlayMediaLabel: UIButton!
    @IBOutlet weak var nextPageButtonLabel: UIButton!


    @IBOutlet weak var ProgresBar: UIProgressView!
    
    
    var moviePlayer: MPMoviePlayerController!

    
    override func viewDidLoad() {
        QuestionImage.hidden = false
        totalQ = self.qData.count
        updateUI()
        println("Quesiton VC loaded")
        println("Question data is \(qData)")
        setQuestion()
    }
    
    func updateUI(){
        self.ProgresBar.setProgress(Float(self.index) / Float(self.totalQ), animated: true)
    }
    
    func endQuizToPeformances(){
        var pvc: PerformanceViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PerformancesViewControllerId") as! PerformanceViewController
        pvc.userAnswers = self.userAnswers
        pvc.userScore = self.score
        pvc.totalScore = self.totalQ
        pvc.activityId = self.activityId
        presentViewController(pvc, animated: true, completion: nil)
    }
    
    func checkIfEnd() -> Bool{
        if self.index  == self.totalQ {
            self.nextPageButtonLabel.hidden = true
            println("It is end because index: \(self.index + 1) and total: \(self.totalQ)")
            endQuizToPeformances()
            return true
        } else {
            return false
        }
    }
    
    func setQuestion(){
        var isEnd = checkIfEnd()
        if isEnd == false {
            self.thisQuestion = qData[index] as! NSDictionary
            var type = thisQuestion["page_type"] as! String
            if type == "question" {
                println("Index is \(self.index)")
                println("This question data is \(thisQuestion)")
                var goodAnswer = thisQuestion["correct_answer"] as! String
                var badAnswer1 = thisQuestion["incorrect_answer_1"] as! String
                var badAnswer2 = thisQuestion["incorrect_answer_2"] as! String
                var badAnswer3 = thisQuestion["incorrect_answer_3"] as! String

                var question = thisQuestion["question"] as! String
                self.QuestionLabel.text = question
                self.answers = []
                self.answers.append(goodAnswer)
                self.answers.append(badAnswer1)
                self.answers.append(badAnswer2)
                self.answers.append(badAnswer3)
                var newAnswers = Utility.shuffle(self.answers)
                
                self.Answer1Label.hidden = false
                self.Answer2Label.hidden = false
                self.Answer3Label.hidden = false
                self.Answer4Label.hidden = false
                self.QuestionLabel.hidden = false
                self.PlayMediaLabel.hidden = true

                
                self.correctAnswer = goodAnswer
                self.Answer1Label.setTitle(newAnswers[0], forState: .Normal)
                self.Answer2Label.setTitle(newAnswers[1], forState: .Normal)
                self.Answer3Label.setTitle(newAnswers[2], forState: .Normal)
                self.Answer4Label.setTitle(newAnswers[3], forState: .Normal)
                var img: String? = thisQuestion["url_image_local"] as? String
                if let image = img {
                    var urlImageLocal: NSString = thisQuestion["url_image_local"] as! NSString
                    println("Local image name is ...\(urlImageLocal)")
                    var filePath = Utility.createFilePathInDocsDir(urlImageLocal as String)
                    var fileExists = Utility.checkIfFileExistsAtPath(filePath)
                    if fileExists == true {
                        println("Image is present called \(filePath)")
                        self.QuestionImage.image = UIImage(named: filePath)
                    } else {
                        println("Unable to find image. Will write to write from network")
                        writeImagesLocally(thisQuestion)
                    }
                }
                var urlMediaRemote:String? = thisQuestion["url_media_remote"] as? String
                if let urlMediaRemote = urlMediaRemote {
                    self.PlayMediaLabel.hidden = false
                } else {
                    self.PlayMediaLabel.hidden = true
                }
                
            } else {
                self.Answer1Label.hidden = true
                self.Answer2Label.hidden = true
                self.Answer3Label.hidden = true
                self.Answer4Label.hidden = true
                self.QuestionLabel.hidden = true
                
                
                var urlMediaRemote:String? = thisQuestion["url_media_remote"] as? String
                if let newUrlMediaRemote = urlMediaRemote {
                    if newUrlMediaRemote != "" {
                        println("There is a remote media file \(newUrlMediaRemote)")
                        self.PlayMediaLabel.hidden = false
                    } else {
                        self.PlayMediaLabel.hidden = true
                    }
                } else {
                    println("There is NOT a remote media file")

                    self.PlayMediaLabel.hidden = true
                }
                
                var urlImageLocal: NSString = thisQuestion["url_image_local"] as! NSString
                println("Local image name is ...\(urlImageLocal)")
                var filePath = Utility.createFilePathInDocsDir(urlImageLocal as String)
                var fileExists = Utility.checkIfFileExistsAtPath(filePath)
                if fileExists == true {
                    println("Image is present called \(filePath)")
                    self.QuestionImage.image = UIImage(named: filePath)
                } else {
                    println("Unable to find image. Will write to write from network")
                    writeImagesLocally(thisQuestion)
                }
                

            }
        } else {
            println("It is the end!")
        }
    }
    
    @IBAction func PlayMedia(sender: AnyObject) {
        
//        var urlMediaLocal = self.thisQuestion["url_media_local"] as? NSString
//        if let urlMediaLocal = urlMediaLocal {
//            var filePath = Utility.createFilePathInDocsDir(urlMediaLocal as String)
//            var fileExists = Utility.checkIfFileExistsAtPath(filePath)
//            if fileExists == true {
//                println("Image is present called \(filePath)")
//                self.QuestionImage.image = UIImage(named: filePath)
//            } else {
//                println("Unable to find image. Will write to write from network")
//                writeImagesLocally(thisQuestion)
//            }
//        }
            var device = UIDevice.currentDevice().userInterfaceIdiom
            var urlpath: NSURL!
            var urlMediaRemote = self.thisQuestion["url_media_remote"] as? String
            if let urlMediaRemote = urlMediaRemote {
                urlpath = NSURL(string: urlMediaRemote)!

                println("url path is \(urlpath)")
                self.moviePlayer = MPMoviePlayerController(contentURL: urlpath!)
                self.moviePlayer.view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.view.addSubview(self.moviePlayer.view)
                self.moviePlayer.controlStyle = MPMovieControlStyle.Fullscreen
                self.moviePlayer.fullscreen = true
                self.moviePlayer.play()
        }
    }
    
    @IBAction func NextPageButton(sender: AnyObject) {
        self.index++
        setQuestion()
    }
    
    @IBAction func Answer1Button(sender: AnyObject) {
        println("Answer 1 chosen")
        if Answer1Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
        }
        var answer = Answer1Label.titleLabel?.text
        addQuestionToUserQuestions(answer!)
        self.index++
        
        setQuestion()
    }
    
    @IBAction func Answer2Button(sender: AnyObject) {
        println("Answer 2 chosen")
        if Answer2Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
        }
        var answer = Answer2Label.titleLabel?.text
        addQuestionToUserQuestions(answer!)
        self.index++
        setQuestion()
    }
    
    
    @IBAction func Answer3Button(sender: AnyObject) {
        println("Answer 3 chosen")
        if Answer3Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
        }
        var answer = Answer3Label.titleLabel?.text
        addQuestionToUserQuestions(answer!)
        self.index++
        setQuestion()
    }
    
    @IBAction func Answer4Button(sender: AnyObject) {
        println("Answer 4 chosen")
        if Answer4Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
        }
        var answer = Answer4Label.titleLabel?.text
        addQuestionToUserQuestions(answer!)
        self.index++
        setQuestion()
    }
    
    func addQuestionToUserQuestions(answer: String){
        let question = self.thisQuestion["question"] as! String
        let correct_answer = self.thisQuestion["correct_answer"] as! String
        let incorrect_answer_1 = self.thisQuestion["incorrect_answer_1"] as! String
        let incorrect_answer_2 = self.thisQuestion["incorrect_answer_2"] as! String
        let incorrect_answer_3 = self.thisQuestion["incorrect_answer_3"] as! String
        let questionDict:Dictionary<String,String> = ["question":question, "correct_answer":correct_answer, "incorrect_answer_1":incorrect_answer_1, "incorrect_answer_2": incorrect_answer_2, "incorrect_answer_3": incorrect_answer_3, "user_answer": answer]
//        println("User question dictionary is \(questionDict)")
        self.userAnswers.addObject(questionDict)
//        println("User answers array looks like...\(self.userAnswers)")
    }
    
    @IBAction func EndQuiz(sender: AnyObject) {
        println("Ending quiz")
        var vc: ComprehensionsIndexController = self.storyboard?.instantiateViewControllerWithIdentifier("ComprehensionsIndexID") as! ComprehensionsIndexController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func writeImagesLocally(dataInput: NSDictionary) {
        var localImageFilename: NSString?
        localImageFilename = dataInput["url_image_local"] as? NSString
        var remoteImageFilename: NSString?
        remoteImageFilename = dataInput["url_image_remote"] as? NSString
        println("Remote image filename \(remoteImageFilename)")
        if let ImgLocal = localImageFilename {
            var imgPathAsString: String = ImgLocal as! String
            var imgPathAsStringExtra = Utility.createFilePathInDocsDir(imgPathAsString)
            println("Inside image local. \(imgPathAsStringExtra)")
            var fileExists = Utility.checkIfFileExistsAtPath(imgPathAsStringExtra)
            if fileExists == true {
                println("Local file exists at \(imgPathAsStringExtra)")
            } else {
                println("Local file does not exist. Was named \(ImgLocal). About to get remote url and pull from network")
                if let ImgRemote: NSString = remoteImageFilename {
                    println("Network location is \(ImgRemote)")
                    let URL = NSURL(string: ImgRemote as String)
                    println("Converted string to URL")
                    let qos = Int(QOS_CLASS_USER_INITIATED.value)
                    println("About to run async off main queue")
                    dispatch_async(dispatch_get_global_queue(qos, 0)){() -> Void in
                        let imageData = NSData(contentsOfURL: URL!)
                        println("Got image data. About to write it")
                        var localPath:NSString = Utility.documentsPathForFileName(ImgLocal as String)
                        imageData!.writeToFile(localPath as String, atomically: true)
                        println("Written image as data to \(localPath)")
                        dispatch_async(dispatch_get_main_queue()){
                            if Utility.checkIfFileExistsAtPath(localPath as String) == true {
                                println("File does exist. Reloading collection table")
                                self.QuestionImage.image = UIImage(named: localPath as String)
                            } else {
                                println("No luck with image local or remote")
                            }
                        }
                    }
                } else {
                    println("remote Image filename empty")
                }
            }
        }
    }
    
}
