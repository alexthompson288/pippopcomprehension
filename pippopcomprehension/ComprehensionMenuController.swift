//
//  ComprehensionMenuController.swift
//  pippopcomprehension
//
//  Created by Alex Thompson on 07/06/2015.
//  Copyright (c) 2015 Alex Thompson. All rights reserved.
//

import Foundation
import UIKit

class ComprehensionMenuController: UIViewController {
    
    var urlImgLocal = ""
    var readingData = NSArray()
    var questionsData = NSArray()
    
    @IBOutlet weak var ComprehensionImage: UIImageView!
    
    override func viewDidLoad() {
        println("Menu VC loaded.")
        println("Url image local is \(urlImgLocal)")
        self.ComprehensionImage.image = UIImage(named: urlImgLocal)
    }
    
    
    @IBAction func GoToQuizButton(sender: AnyObject) {
        var vc:QuestionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("QuizID") as! QuestionViewController
        vc.qData = questionsData
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func GoToReadingButton(sender: AnyObject) {
        var vc:ReadingContentController = self.storyboard?.instantiateViewControllerWithIdentifier("ReadingContentID") as! ReadingContentController
        vc.activityData = readingData
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func BackButton(sender: AnyObject) {
        var vc:ComprehensionCollectionController = self.storyboard?.instantiateViewControllerWithIdentifier("ComprehensionCollectionID") as! ComprehensionCollectionController
        self.presentViewController(vc, animated: true, completion: nil)
    }
}
