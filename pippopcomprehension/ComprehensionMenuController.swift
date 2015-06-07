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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MenuToReadingSegue" {
            println("Setting data before sgue to menu to reading")
            var vc:ReadingContentController = segue.destinationViewController as! ReadingContentController
            vc.activityData = readingData
        } else if segue.identifier == "MenuToQuestionsSegue" {
            println("Setting data before sgue to questions")
            var vc:QuestionViewController = segue.destinationViewController as! QuestionViewController
            vc.qData = questionsData
        }
    }
    
}
