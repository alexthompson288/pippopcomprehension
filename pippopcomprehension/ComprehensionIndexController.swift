//
//  ComprehensionIndexController.swift
//  pippopcomprehension
//
//  Created by Alex Thompson on 17/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import UIKit
import StoreKit

class ComprehensionsIndexController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var ComprehensionsCollectionView: UICollectionView!
    
    let filemgr = NSFileManager.defaultManager()
    var JSONData = NSDictionary()
    var totalData = NSArray() {didSet {updateUI()}}
    var access_token: String!
    var learnerID: Int?
    var learnerName: String?
    var learners = []
    var learnerScores: NSArray?
    var totalStars = 5
    var starCount:Int?

    
    override func viewDidLoad() {
        self.access_token = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as! String
        self.ComprehensionsCollectionView.delegate = self
        self.ComprehensionsCollectionView.dataSource = self
        setLearnersData()
        loadScoreData()
        getScoreData()
        loadData()
        getFreshData()
    }
    
    override func viewWillAppear(animated: Bool) {
        println("View appearing...")
        updateUI()
    }
    
    func updateUI(){
        println("Updating UI...")
        dispatch_async(dispatch_get_main_queue()){
            println("About to refresh table. Data count is \(self.totalData.count). Data is \(self.totalData)")
            self.ComprehensionsCollectionView.reloadData()
        }
    }
    
    @IBAction func ChangeLearnersButton(sender: AnyObject) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            println("Number of items function...: \(self.totalData.count)")
            return totalData.count
        }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        println("This line...")
        println("Deque cell \(indexPath.row)")
        var id:Int = totalData[indexPath.row]["id"] as! Int
        var title:NSString = totalData[indexPath.row]["title"] as! NSString
        var urlImageLocal: NSString = totalData[indexPath.row]["url_image_local"] as! NSString
        var thisDict:NSDictionary = totalData[indexPath.row] as! NSDictionary
        var cell:ComprehensionIndexCell = collectionView.dequeueReusableCellWithReuseIdentifier("ComprehensionIndexCellID", forIndexPath: indexPath) as! ComprehensionIndexCell
        var stage:String = totalData[indexPath.row]["stage"] as! String
        if let myLearnerScores = self.learnerScores {
            for score in myLearnerScores {
                var compId = score["id"] as! Int
                if compId == id {
                    var stars:Int = score["stars"] as! Int
                    self.starCount = stars
                }
            }
        }
        
        var offlineStatus = comprehensionIsLocal(totalData[indexPath.row] as! NSDictionary)
        println("Offline status is \(offlineStatus)")
        
        
        
        //        SET MAIN IMAGE
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 10, y: 0, width: cell.frame.width - 20, height: 200)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        cell.addSubview(imageView)
        var filePath = Utility.createFilePathInDocsDir(urlImageLocal as String)
        var fileExists = Utility.checkIfFileExistsAtPath(filePath)
        if fileExists == true {
            println("Image is present called \(filePath)")
            imageView.image = UIImage(named: filePath)
        } else {
            println("Unable to find image. Will write to write from network")
            writeImagesLocally(thisDict)
        }
        
//        SET STARS
        if let starCount = self.starCount {
            for var i = 0; i < self.totalStars; i++
            {
                let imageView = UIImageView()
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                var widthFloat = CGFloat()
                var width = Int()
                
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    widthFloat = cell.frame.width - 100
                    widthFloat = widthFloat / 5
                    width = Int(widthFloat)
                    width = width * i
                    width = width + 50
                }
                else {
                    widthFloat = cell.frame.width
                    widthFloat = widthFloat / 5
                    width = Int(widthFloat)
                    width = width * i
                    width = width + 5
                }

               
//                var height = Int(cell.frame.height - 100)
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    imageView.frame = CGRect(x: width, y: 205, width: 30, height: 30)
                } else {
                    imageView.frame = CGRect(x: width, y: 205, width: 25, height: 25)
                }
                if i < starCount {
                    imageView.image = UIImage(named: "star_active")
                } else {
                    imageView.image = UIImage(named: "star_inactive")
                }
                cell.addSubview(imageView)
            }
        }
        
//        SET DOWNLOAD BUTTON
        let downloadButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        downloadButton.frame = CGRectMake(50,245, cell.frame.width - 100, 40)
        downloadButton.backgroundColor = UIColor.greenColor()
        downloadButton.tag = id
        downloadButton.layer.cornerRadius = 10.0;
        downloadButton.layer.borderColor = UIColor(red: 255, green: 217, blue: 84).CGColor
        downloadButton.layer.borderWidth = 3
        downloadButton.backgroundColor = ColourValues.yellowColor
        if offlineStatus == true {
            downloadButton.setTitle("Delete", forState: UIControlState.Normal)
            downloadButton.addTarget(self, action: "deleteMedia:", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            downloadButton.setTitle("Download", forState: UIControlState.Normal)
            downloadButton.addTarget(self, action: "downloadMedia:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        cell.addSubview(downloadButton)
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.contentView.layer.cornerRadius = 8
        
        
        
        var titleLabel = UILabel(frame: CGRectMake(0, 0, 100, 21))
        titleLabel.center = CGPointMake(160, 284)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "I am a test label"
        
        
        var difficultyLabel = UILabel(frame: CGRectMake(0, 0, 100, 21))
        difficultyLabel.center = CGPointMake(20, 30)
        difficultyLabel.textAlignment = NSTextAlignment.Center
        difficultyLabel.text = "\(stage)"
        


        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return CGSizeMake(300, 320)
        } else {
            return CGSizeMake(200, 300)
        }
    }
    

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var vc: QuestionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("QuizID") as! QuestionViewController
        var rData = totalData[indexPath.row]["pages"] as! NSArray
        var titleOverview = totalData[indexPath.row]["title"] as! String
        var descriptionOverview = totalData[indexPath.row]["overview"] as! String
        println("Reading data is \(rData).")
        vc.qData = rData
        var urlImageLocal: NSString = totalData[indexPath.row]["url_image_local"] as! NSString
        var filePath = Utility.createFilePathInDocsDir(urlImageLocal as String)
        vc.activityId = totalData[indexPath.row]["id"] as! Int
        var totalQuestions = totalData[indexPath.row]["total_questions"] as! Int
        vc.totalQuestions = totalQuestions
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
//        UIView.animateWithDuration(0.25, animations: {
//            cell.layer.transform = CATransform3DMakeScale(1,1,1)
//        })
    }
    
    func loadData() {
//        self.ActivitySpinner.hidden = false
//        self.ActivitySpinner.startAnimating()
        println("Starting the loadData function")
        
        var filePath = Utility.createFilePathInDocsDir("data.plist")
        var fileExists = Utility.checkIfFileExistsAtPath(filePath)
        if fileExists {
            println("File exists...")
            var data = Utility.loadJSONDataAtFilePath(filePath)
            let exps = data["comprehensions"] as! NSArray
            self.totalData = exps
            println("Number of comps is \(exps.count)")
//            self.ActivitySpinner.stopAnimating()
//            self.ActivitySpinner.hidden = true
            return;
            
            
        } else {
            var url = Constants.apiUrl
            println("File doesn't exist locally. Constant is \(url)")
            if let learner = self.learnerID {
                println("Getting JSON FROM SERVER FOR BOOKS")
                getJSON(url, token: self.access_token, learner_id: learner)
            } else {
                println("There is no value inside of learner")
            }
        }
    }
    
    func getFreshData(){
        var url = Constants.apiUrl
        if let learner = self.learnerID {
            println("Getting FRESH JSON FROM SERVER FOR COMPREHENSIONS ")
            getJSON(url, token: self.access_token, learner_id: learner)
        } else {
            println("There is no value inside of learner")
        }
    }
    
    func getScoreData(){
        var url = Constants.scoreDataUrl
        println("Getting scores data from servers...")
        getScoresJSON(url, token: self.access_token)
    }
    
    func loadScoreData(){
        var filePath = Utility.createFilePathInDocsDir("scores.plist")
        var fileExists = Utility.checkIfFileExistsAtPath(filePath)
        if fileExists {
            println("Scores file exists...")
            var data = Utility.loadJSONDataAtFilePath(filePath)
            let myLearners = data["learners"] as! NSArray
            println("Number of learners \(learners.count)")
            for learner in myLearners {
                var id = learner["id"] as? Int
                if let lId = id {
                    if let currentLearnerId = learnerID {
                        if lId == currentLearnerId {
                            var scores = learner["comprehension_scores"] as? NSArray
                            if let myScores = scores {
                                println("Setting learner scores...")
                                self.learnerScores = myScores
                            }
                        }
                    }
                }
            }
            
            return;
            
        } else {
            println("Could not load the score data...")
        }
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
                self.loadData()
//                self.ActivitySpinner.stopAnimating()
//                self.ActivitySpinner.hidden = true
            }
        }
        task.resume()
    }

    func getScoresJSON(api:String, token: String) {
        let url = NSURL(string: api)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "GET"
        request.addValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            if error != nil {
                println("Error hitting Scores API")
                return
            } else {
                println("Received scores data...\(data)")
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                var encodedJSON:NSDictionary = Utility.dataToJSON(data)
                Utility.saveJSONWithArchiver(encodedJSON, savedName: "scores.plist")
                self.loadScoreData()
                //                self.ActivitySpinner.stopAnimating()
                //                self.ActivitySpinner.hidden = true
            }
        }
        task.resume()
    }

    
    
    func setLearnersData(){
        var filepath = Utility.createFilePathInDocsDir("userData.plist")
        var dataPresent = Utility.checkIfFileExistsAtPath(filepath)
        if dataPresent{
            var data = Utility.loadJSONDataAtFilePath(filepath)
            var ownerName = data["name"] as! String
            var ownerId = data["id"] as! Int
            var ownerType = data["user_type"] as! String
            NSUserDefaults.standardUserDefaults().setObject(ownerName, forKey: "ownerName")
            NSUserDefaults.standardUserDefaults().setObject(ownerId, forKey: "ownerID")
            NSUserDefaults.standardUserDefaults().setObject(ownerType, forKey: "ownerType")
            
            
            learners = data["learners"] as! NSArray
            if let currentLearner = NSUserDefaults.standardUserDefaults().objectForKey("learnerID") as? Int {
                self.learnerID = currentLearner
                self.learnerName = NSUserDefaults.standardUserDefaults().objectForKey("learnerName") as? String
            } else {
                for learner in learners {
                    var name: String = learner["name"] as! String
                    println("Learner name is \(name)")
                }
                var firstLearner:NSDictionary = learners[0] as! NSDictionary
                var name = firstLearner["name"] as! String
                var id = firstLearner["id"] as! Int
                var premium_access = firstLearner["premium_access"] as! Bool
                println("Setting new first learner. Premium access is...\(premium_access)")
                NSUserDefaults.standardUserDefaults().setObject(name, forKey: "learnerName")
                NSUserDefaults.standardUserDefaults().setObject(id, forKey: "learnerID")
                self.learnerID = NSUserDefaults.standardUserDefaults().objectForKey("learnerID") as? Int
                NSUserDefaults.standardUserDefaults().setObject(premium_access, forKey: "premium_access")
                
                learnerName = NSUserDefaults.standardUserDefaults().objectForKey("learnerName") as? String
            }
        }
        
        if let name = learnerName {
//            self.LoggedInAsLabel.text = "Logged in as \(name)"
        }
    }
    
    @IBAction func GoToSettingsButton(sender: AnyObject) {
        var svc:SettingsTableController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsTableControllerId") as! SettingsTableController
        svc.learners = self.learners
        if let name = self.learnerName {
            svc.learnerName = name
        }
        presentViewController(svc, animated: true, completion: nil)
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
                                self.ComprehensionsCollectionView.reloadData()
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
    
    func writeMediaLocally(dataInput: NSDictionary, comprehension: NSDictionary) {
//        SET OPTIONAL VARIABLES
        var localImageFilename = dataInput["url_image_local"] as? String
        var remoteImageFilename = dataInput["url_image_remote"] as? String
        var localMediaFilename = dataInput["url_media_local"] as? String
        var remoteMediaFilename = dataInput["url_media_remote"] as? String
        
//        CHECK IF LOCAL IMAGE ELSE WRITE IT
        if let ImgLocal = localImageFilename {
            var imgPath = Utility.createFilePathInDocsDir(ImgLocal)
            println("Inside image local. \(imgPath)")
            var fileExists = Utility.checkIfFileExistsAtPath(imgPath)
            if fileExists == true {
                println("Local file exists at \(imgPath)")
            } else {
                println("Local file does not exist. Was named \(ImgLocal). About to get remote url and pull from network")
                if let ImgRemote = remoteImageFilename {
                    writeFileLocally(ImgRemote, filename: ImgLocal)
                    if comprehensionIsLocal(comprehension) { updateUI() }
                } else {
                    println("remote Image filename empty")
                }
            }
        }
        
        if let MediaLocal = localMediaFilename {
            var mediaPath = Utility.createFilePathInDocsDir(MediaLocal)
            println("Inside image local. \(mediaPath)")
            var fileExists = Utility.checkIfFileExistsAtPath(mediaPath)
            if fileExists == true {
                println("Local file exists at \(mediaPath)")
            } else {
                println("Local file does not exist. Was named \(MediaLocal). About to get remote url and pull from network")
                if let MediaRemote = remoteMediaFilename {
                    writeFileLocally(MediaRemote, filename: MediaLocal)
                    if comprehensionIsLocal(comprehension) { updateUI() }
                } else {
                    println("remote media filename empty")
                }
            }
        }
    }
    
    func deleteMediaLocally(dataInput: NSDictionary) {
        //        SET OPTIONAL VARIABLES
        var localImageFilename = dataInput["url_image_local"] as? String
        var localMediaFilename = dataInput["url_media_local"] as? String
        
        //        CHECK IF LOCAL IMAGE ELSE WRITE IT
        if let ImgLocal = localImageFilename {
            if ImgLocal != "" {
                var imgPath = Utility.createFilePathInDocsDir(ImgLocal)
                println("Inside image local. \(imgPath)")
                var fileExists = Utility.checkIfFileExistsAtPath(imgPath)
                if fileExists == true {
                    NSFileManager.defaultManager().removeItemAtPath(imgPath as String, error: nil)
                    println("Deleting file at \(imgPath)")
                } else {
                    println("Did not delete file. Never existed")
                }
            }
        }
        
        if let MediaLocal = localMediaFilename {
            if MediaLocal != "" {
                var mediaPath = Utility.createFilePathInDocsDir(MediaLocal)
                println("Inside image local. \(mediaPath)")
                var fileExists = Utility.checkIfFileExistsAtPath(mediaPath)
                if fileExists == true {
                    NSFileManager.defaultManager().removeItemAtPath(mediaPath as String, error: nil)
                    println("Deleting file at \(mediaPath)")
                } else {
                    println("Did not delete file. Never existed")
                }
            }
        }
    }
    
    func writeFileLocally(filePath: String, filename: String){
        println("Network location is \(filePath)")
        let URL = NSURL(string: filePath)
        println("Converted string to URL")
        let qos = Int(QOS_CLASS_USER_INITIATED.value)
        println("About to run async off main queue")
        dispatch_async(dispatch_get_global_queue(qos, 0)){() -> Void in
            let imageData = NSData(contentsOfURL: URL!)
            println("Got image data. About to write it")
            var localPath:NSString = Utility.documentsPathForFileName(filename)
            imageData!.writeToFile(localPath as String, atomically: true)
            println("Written image as data to \(localPath)")
            dispatch_async(dispatch_get_main_queue()){
                if Utility.checkIfFileExistsAtPath(localPath as String) == true {
                    println("File successfully written")
                } else {
                    println("No luck with image local or remote")
                }
            }
        }
    }
    
    func comprehensionIsLocal(comprehension: NSDictionary) -> Bool {
        var questions = comprehension["pages"] as! NSArray
        for question in questions {
            var imgLocal = question["url_image_local"] as? String
            var mediaLocal = question["url_media_local"] as? String
            if let imgLocal = imgLocal {
                if imgLocal != "" {
                    var filePath = Utility.createFilePathInDocsDir(imgLocal as String)
                    var fileExists = Utility.checkIfFileExistsAtPath(filePath)
                    println("\(fileExists) that img file exists at \(filePath).")
                    if fileExists == false {
                        return false
                    }
                }
            }
            if let mediaLocal = mediaLocal {
                if mediaLocal != "" {
                    var filePath = Utility.createFilePathInDocsDir(mediaLocal as String)
                    var fileExists = Utility.checkIfFileExistsAtPath(filePath)
                    println("\(fileExists) that media file exists at \(filePath).")
                    if fileExists == false {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func downloadMedia(sender: UIButton){
        println("Downloading media...")
        var thisCompId = sender.tag as Int
        for comp in totalData {
            var compId = comp["id"] as! Int
            if compId == thisCompId {
                var thisComp = comp as! NSDictionary
                var questions = thisComp["pages"] as! NSArray
                for question in questions {
                    writeMediaLocally(question as! NSDictionary, comprehension: comp as! NSDictionary)
                }
                println("Successfully downloaded all media...")
            }
            
        }
    }
    
    func deleteMedia(sender: UIButton){
        println("Deleting media...")
        var thisCompId = sender.tag as Int
        for comp in totalData {
            var compId = comp["id"] as! Int
            if compId == thisCompId {
                var thisComp = comp as! NSDictionary
                var questions = thisComp["pages"] as! NSArray
                for question in questions {
                    deleteMediaLocally(question as! NSDictionary)
                }
            }
            
        }
    }
    
}

