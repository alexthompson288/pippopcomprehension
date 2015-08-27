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
import AVFoundation

class QuestionViewController: UIViewController {

    var qData = NSArray()
    var index = 0 { didSet {
        updateUI()
        checkIfEnd()
        }
    }
    var totalQuestions = Int()
    var totalPages = Int()

    var score = 0 {didSet { updateUI() }}
    var correctAnswer = ""
    var answers = [String]()
    var thisQuestion = NSDictionary()
    var userAnswers = NSMutableArray()
    var activityId = Int()
    var autoplay = Bool()
    var mediatype = String()
    
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var QuestionImage: UIImageView!
    @IBOutlet weak var Answer1Label: UIButton!
    @IBOutlet weak var Answer2Label: UIButton!
    @IBOutlet weak var Answer3Label: UIButton!
    @IBOutlet weak var Answer4Label: UIButton!
    @IBOutlet weak var EndQuizLabel: UIButton!
    @IBOutlet weak var PlayMediaLabel: UIButton!
    @IBOutlet weak var nextPageButtonLabel: UIButton!
    @IBOutlet weak var QuestionPageImage: UIImageView!


    @IBOutlet weak var ProgresBar: UIProgressView!
    
    
    var moviePlayer: MPMoviePlayerController!
    var audioPlayer = AVAudioPlayer()

    
    override func viewDidLoad() {
        ProgresBar.layer.cornerRadius = 10
        var audioVal = NSUserDefaults.standardUserDefaults().objectForKey("audio_instructions") as? Bool
        if let audioVal = audioVal {
            println("Autoplay instructions is \(audioVal)")
            self.autoplay = audioVal
        }
        self.moviePlayer = MPMoviePlayerController()
        self.totalPages = self.qData.count
        QuestionImage.hidden = false
        updateUI()
        println("Quesiton VC loaded")
        println("Question data is \(qData)")
        setQuestion()
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        self.nextPageButtonLabel.hidden = true
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                println("Swiped right")
            case UISwipeGestureRecognizerDirection.Down:
                println("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                println("Swiped left")
                pullViewToLeft()
                self.index++
                self.moviePlayer.stop()
                let delay = 0.1 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    self.setQuestion()
                }
                
            default:
                break
            }
        }
    }
    
    func updateUI(){
        self.ProgresBar.setProgress(Float(self.index) / Float(self.totalPages), animated: true)
    }
    
    func endQuizToPeformances(){
        var pvc: PerformanceViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PerformancesViewControllerId") as! PerformanceViewController
        pvc.userAnswers = self.userAnswers
        pvc.userScore = self.score
        pvc.totalScore = self.totalQuestions
        pvc.activityId = self.activityId
        presentViewController(pvc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        println("View appearing")
        self.moviePlayer.stop()
    }
    
    func pullViewToLeft(){
        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseInOut, animations: {
            var viewframe = self.view.frame
            viewframe.origin.x -= 80
            self.view.frame = viewframe
            println("View frame pull to left is \(self.view.frame)")
            }, completion: { finished in
                println("Animation complete!")
        })
    }
    
    func pullViewFromLeft(){
        self.view.frame.origin.x = 40

        UIView.animateWithDuration(0.9, delay: 0.0, options: .CurveEaseInOut, animations: {
            var viewframe = self.view.frame
            viewframe.origin.x = 0
            self.view.frame = viewframe
            println("View frame pull from left is \(self.view.frame)")

            
            }, completion: { finished in
                println("Animation complete!")
        })
    }
    
    
    
    func checkIfEnd() -> Bool{
        if self.index  == self.totalPages {
            self.nextPageButtonLabel.hidden = true
            println("It is end because index: \(self.index + 1) and total: \(self.totalQuestions)")
            endQuizToPeformances()
            return true
        } else {
            return false
        }
    }
    
    func setQuestion(){
        pullViewFromLeft()
        view.userInteractionEnabled = true

        self.QuestionPageImage.image = nil
        self.QuestionImage.image = nil
        self.view.backgroundColor = UIColor.blackColor()
        var isEnd = checkIfEnd()
        if isEnd == false {
            self.thisQuestion = qData[index] as! NSDictionary
            var type = thisQuestion["page_type"] as! String
            if type == "question" {
                println("Index is \(self.index)")
//                println("This question data is \(thisQuestion)")
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
                
                
                Answer1Label.layer.backgroundColor = UIColor.yellowColor().CGColor
                Answer2Label.layer.backgroundColor = UIColor.yellowColor().CGColor
                Answer3Label.layer.backgroundColor = UIColor.yellowColor().CGColor
                Answer4Label.layer.backgroundColor = UIColor.yellowColor().CGColor

                
                self.Answer1Label.hidden = false
                self.Answer2Label.hidden = false
                self.Answer3Label.hidden = false
                self.Answer4Label.hidden = false
                self.QuestionLabel.hidden = false
                self.QuestionImage.hidden = true
                self.QuestionPageImage.hidden = false
                self.PlayMediaLabel.hidden = true
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    self.QuestionLabel.font = UIFont(name: self.QuestionLabel.font.fontName, size: 40)
                    self.Answer1Label.titleLabel?.font = UIFont(name: self.QuestionLabel.font.fontName, size: 26)
                    self.Answer2Label.titleLabel?.font = UIFont(name: self.QuestionLabel.font.fontName, size: 26)
                    self.Answer3Label.titleLabel?.font = UIFont(name: self.QuestionLabel.font.fontName, size: 26)
                    self.Answer4Label.titleLabel?.font = UIFont(name: self.QuestionLabel.font.fontName, size: 26)
                    println("Making larger font for iPad")
                }

                
                self.correctAnswer = goodAnswer
                self.Answer1Label.setTitle(newAnswers[0], forState: .Normal)
                self.Answer2Label.setTitle(newAnswers[1], forState: .Normal)
                self.Answer3Label.setTitle(newAnswers[2], forState: .Normal)
                self.Answer4Label.setTitle(newAnswers[3], forState: .Normal)
                var imgLocal: String? = thisQuestion["url_image_local"] as? String
                if let urlImageLocal = imgLocal {
                    if urlImageLocal != ""{
                        println("Local image name is ...\(urlImageLocal)")
                        var filePath = Utility.createFilePathInDocsDir(urlImageLocal as String)
                        var fileExists = Utility.checkIfFileExistsAtPath(filePath)
                        if fileExists == true {
                            println("Image is saved locally - called \(filePath)")
                            self.QuestionPageImage.image = UIImage(named: filePath)
                        } else {
                            println("Unable to find image. Will write to write from network")
                            writeImagesLocally(thisQuestion)
                        }
                        
                    } else {
                        println("Adding tick image because none present")
                        self.QuestionPageImage.image = UIImage(named: "confused")
                    }
                } else {
                    println("Adding tick image because none present")
                    self.QuestionPageImage.image = UIImage(named: "confused")
                }
                var urlMediaRemote:String? = thisQuestion["url_media_remote"] as? String
                if let urlMediaRemote = urlMediaRemote {
                    self.PlayMediaLabel.hidden = false
                } else {
                    self.PlayMediaLabel.hidden = true
                }
                animateInAnswers()
                
            } else {
                
//                TYPE IS MEDIA PAGE
                self.Answer1Label.hidden = true
                self.Answer2Label.hidden = true
                self.Answer3Label.hidden = true
                self.Answer4Label.hidden = true
                self.QuestionLabel.hidden = true
                self.QuestionPageImage.hidden = true
                self.QuestionImage.hidden = false
                
                
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
                
                self.mediatype = thisQuestion["media_type"] as! String
                
//                IF WE HAVE A VIDEO THEN AUTOPLAY
                if self.mediatype == "video" {
                    var urlpath: NSURL!
                    
//                    IF VIDEO IS LOCAL SET LOCAL URL
                    var videoIsLocal = false
                    var urlMediaLocal = self.thisQuestion["url_media_local"] as? String
                    if let urlMediaLocal = urlMediaLocal {
                        if urlMediaLocal != "" {
                            var mediaPath = Utility.createFilePathInDocsDir(urlMediaLocal)
                            println("Inside video local. \(mediaPath)")
                            var fileExists = Utility.checkIfFileExistsAtPath(mediaPath)
                            if fileExists == true {
                                videoIsLocal = true
                                println("File exists so setting url to local...")
                                if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                                    urlpath = directoryURL.URLByAppendingPathComponent(urlMediaLocal)
                                }
                            } else {
                                println("No local url. Setting remote...")
                                //                    ELSE SET REMOTE URL
                                videoIsLocal = false
                                
                                var urlMediaRemote = self.thisQuestion["url_media_remote"] as? String
                                if let urlMediaRemote = urlMediaRemote {
                                    if urlMediaRemote != ""{
                                        urlpath = NSURL(string: urlMediaRemote)!
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    
//                    PLAY VIDEO FILE
                    var connected: Bool = Reachability.isConnectedToNetwork()
                    
                    
                    if videoIsLocal == false && connected == false {
                        var alert = UIAlertController(title: "Uh oh!", message: "You need internet to stream this video...", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        self.moviePlayer.stop()
                        println("Playing video. Url path is \(urlpath)")
                        self.moviePlayer = MPMoviePlayerController(contentURL: urlpath!)
                        self.moviePlayer.view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                        self.view.addSubview(self.moviePlayer.view)
                        self.moviePlayer.controlStyle = MPMovieControlStyle.Fullscreen
                        self.moviePlayer.fullscreen = true
                        //                        self.moviePlayer.play()

                    }
                    
                } else if self.mediatype == "audio" {
//                    WE HAVE AUDIO
                    var urlpath: NSURL!
                    if self.autoplay == true {
                        var urlMediaLocal = self.thisQuestion["url_media_local"] as? String
                        if let urlMediaLocal = urlMediaLocal {
                            if urlMediaLocal != "" {
                                
//                                SET LOCAL URL IF PRESENT
                                var mediaPath = Utility.createFilePathInDocsDir(urlMediaLocal)
                                println("Inside image local. \(mediaPath)")
                                var fileExists = Utility.checkIfFileExistsAtPath(mediaPath)
                                if fileExists == true {
                                    if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                                        urlpath = directoryURL.URLByAppendingPathComponent(urlMediaLocal)
                                    }
                                } else {
                                    
            //                    ELSE SET REMOTE URL
                                    var urlMediaRemote = self.thisQuestion["url_media_remote"] as? String
                                    if let urlMediaRemote = urlMediaRemote {
                                        if urlMediaRemote != ""{
                                            urlpath = NSURL(string: urlMediaRemote)!
                                        }
                                    }
                                }
                            }
                        }

                        self.moviePlayer.stop()

                        println("Playing audio. Url path is \(urlpath)")
                        self.moviePlayer = MPMoviePlayerController(contentURL: urlpath)
                        self.moviePlayer.view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                        self.view.addSubview(self.moviePlayer.view)
                        self.moviePlayer.controlStyle = MPMovieControlStyle.Fullscreen
                        self.moviePlayer.fullscreen = false
//                            self.moviePlayer.play()
                    }

                }
                
                var urlImageLocal: NSString = thisQuestion["url_image_local"] as! NSString
                println("Local image name is ...\(urlImageLocal)")
                var filePath = Utility.createFilePathInDocsDir(urlImageLocal as String)
                var fileExists = Utility.checkIfFileExistsAtPath(filePath)
                if fileExists == true {
                    println("Image is saved locally - called \(filePath)")
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
            var device = UIDevice.currentDevice().userInterfaceIdiom
            var urlpath: NSURL!
        
            var urlMediaLocal = self.thisQuestion["url_media_local"] as? String
            if let urlMediaLocal = urlMediaLocal {
                if urlMediaLocal != "" {
                    var mediaPath = Utility.createFilePathInDocsDir(urlMediaLocal)
                    println("Inside image local. \(mediaPath)")
                    var fileExists = Utility.checkIfFileExistsAtPath(mediaPath)
                    if fileExists == true {
                        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                            urlpath = directoryURL.URLByAppendingPathComponent(urlMediaLocal)
                        }
                    } else {
                        //                    ELSE SET REMOTE URL
                        
                        var urlMediaRemote = self.thisQuestion["url_media_remote"] as? String
                        if let urlMediaRemote = urlMediaRemote {
                            if urlMediaRemote != ""{
                                urlpath = NSURL(string: urlMediaRemote)!
                            }
                        }
                    }
                    println("In play media action. Url path is \(urlpath)")
                    self.moviePlayer.stop()
                    self.moviePlayer = MPMoviePlayerController(contentURL: urlpath!)
                    self.moviePlayer.view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    self.view.addSubview(self.moviePlayer.view)
                    self.moviePlayer.controlStyle = MPMovieControlStyle.Fullscreen
                    if self.mediatype == "video"{
                        self.moviePlayer.fullscreen = true
                    } else {
                        self.moviePlayer.fullscreen = false
                    }
                    self.moviePlayer.play()

                }
            }
    }
    
    @IBAction func NextPageButton(sender: AnyObject) {
        self.index++
        self.moviePlayer.stop()

        setQuestion()
    }
    
    @IBAction func Answer1Button(sender: AnyObject) {
        println("Answer 1 chosen")
        view.userInteractionEnabled = false
        if Answer1Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
            self.Answer1Label.layer.backgroundColor = UIColor.greenColor().CGColor
        } else {
            self.Answer1Label.layer.backgroundColor = UIColor.redColor().CGColor
        }
        self.index++
        var answer = Answer1Label.titleLabel?.text
        Answer1Label.titleLabel!.textColor = UIColor.whiteColor()
        addQuestionToUserQuestions(answer!)
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.setQuestion()
        }
        
        
        
    }
    
    @IBAction func Answer2Button(sender: AnyObject) {
        view.userInteractionEnabled = false

        println("Answer 2 chosen")
        if Answer2Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
            self.Answer2Label.layer.backgroundColor = UIColor.greenColor().CGColor
        } else {
            self.Answer2Label.layer.backgroundColor = UIColor.redColor().CGColor
        }

        var answer = Answer2Label.titleLabel?.text
        Answer2Label.titleLabel!.textColor = UIColor.whiteColor()
        addQuestionToUserQuestions(answer!)
        self.index++
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.setQuestion()
        }
    }
    
    
    @IBAction func Answer3Button(sender: AnyObject) {
        view.userInteractionEnabled = false

        println("Answer 3 chosen")
        if Answer3Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
            self.Answer3Label.layer.backgroundColor = UIColor.greenColor().CGColor
        } else {
            self.Answer3Label.layer.backgroundColor = UIColor.redColor().CGColor
        }
        Answer3Label.titleLabel!.textColor = UIColor.whiteColor()
        var answer = Answer3Label.titleLabel?.text
        addQuestionToUserQuestions(answer!)
        self.index++
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.setQuestion()
        }
    }
    
    @IBAction func Answer4Button(sender: AnyObject) {
        view.userInteractionEnabled = false

        println("Answer 4 chosen")
        if Answer4Label.titleLabel?.text == correctAnswer {
            println("Correct!")
            self.score++
            self.Answer4Label.layer.backgroundColor = UIColor.greenColor().CGColor
        } else {
            self.Answer4Label.layer.backgroundColor = UIColor.redColor().CGColor
        }
        Answer4Label.titleLabel!.textColor = UIColor.whiteColor()

        var answer = Answer4Label.titleLabel?.text
        addQuestionToUserQuestions(answer!)
        self.index++
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.setQuestion()
        }
    }
    
    func animateCorrect(){
        
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
    
    func animateInAnswers(){
        UIView.animateWithDuration(0.7, delay: 0.1, options: .CurveEaseOut, animations: {
            var answer1frame = self.Answer1Label.frame
            answer1frame.origin.x -= answer1frame.size.height
            self.Answer1Label.frame = answer1frame
            
            
            var answer2frame = self.Answer2Label.frame
            answer2frame.origin.y += answer2frame.size.height
            self.Answer2Label.frame = answer2frame
            
            
            var answer3frame = self.Answer3Label.frame
            answer3frame.origin.y -= answer3frame.size.height
            self.Answer3Label.frame = answer3frame
            
            var answer4frame = self.Answer4Label.frame
            answer4frame.origin.x += answer4frame.size.height
            self.Answer4Label.frame = answer4frame
            
            }, completion: { finished in
                println("Animation complete!")
        })
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
