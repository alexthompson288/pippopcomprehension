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
    
    var totalData = NSArray()

    
    
    override func viewDidLoad() {
    
        self.ComprehensionsCollectionView.delegate = self
        self.ComprehensionsCollectionView.dataSource = self
        loadData()
    }
    
    func updateUI(){
        dispatch_async(dispatch_get_main_queue()){
            //            println("About to refresh table. Data count is \(self.data.count). Data is \(self.data)")
            self.ComprehensionsCollectionView.reloadData()
        }
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
        var title:NSString = totalData[indexPath.row]["title"] as! NSString
        var urlImageLocal: NSString = totalData[indexPath.row]["url_image_local"] as! NSString
        var thisDict:NSDictionary = totalData[indexPath.row] as! NSDictionary
        var cell:ComprehensionIndexCell = collectionView.dequeueReusableCellWithReuseIdentifier("ComprehensionIndexCellID", forIndexPath: indexPath) as! ComprehensionIndexCell
        cell.TitleLabel.text = title as String
        
        var filePath = Utility.createFilePathInDocsDir(urlImageLocal as String)
        var fileExists = Utility.checkIfFileExistsAtPath(filePath)
        if fileExists == true {
            println("Image is present called \(filePath)")
            cell.ComprehensionImage.image = UIImage(named: filePath)
        } else {
            println("Unable to find image. Will write to write from network")
            writeImagesLocally(thisDict)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var vc: ComprehensionMenuController = self.storyboard?.instantiateViewControllerWithIdentifier("ComprehensionMenuID") as! ComprehensionMenuController
        var rData = totalData[indexPath.row]["pages"] as! NSArray
        var qData = totalData[indexPath.row]["questions"] as! NSArray
        var titleOverview = totalData[indexPath.row]["overview"] as! String
        println("Reading data is \(rData).")
        println("Question data is \(qData).")
        vc.readingData = rData
        vc.questionsData = qData
        var urlImageLocal: NSString = totalData[indexPath.row]["url_image_local"] as! NSString
        var filePath = Utility.createFilePathInDocsDir(urlImageLocal as String)
        vc.urlImgLocal = filePath
        vc.titleLabelText = titleOverview
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
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
            
            for exp in exps{
                //                println(exp)
                var imgString = exp["url_image_remote"] as! String
                if imgString != ""{
                    
                    var img = exp["url_image_remote"] as! String
                    var title = exp["title"] as! String
                    println("Total data is \(totalData). ")
                    dispatch_async(dispatch_get_main_queue()){
                        self.ComprehensionsCollectionView.reloadData()
                    }
                }
            }
//            self.ActivitySpinner.stopAnimating()
//            self.ActivitySpinner.hidden = true
            return;
            
            
        } else {
            var url = Constants.apiUrl
            println("File doesn't exist locally. Constant is \(url)")
            getJSON(url)
        }
    }
    
    func getJSON(api:String) {
        let url = NSURL(string: api)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
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

    
    
}

