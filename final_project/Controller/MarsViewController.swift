//
//  ViewController.swift
//  final_project
//
//  Created by Phillip Yang on 4/23/19.
//  Copyright © 2019 Phillip Yang. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SwiftyJSON



class MarsViewController: UIViewController {

    // variables
    private let API_KEY = "RzyT98G4RWi51f3LYNHdbdEzUJkUH7RdAJnQoOd0"
    private var todaysDateString: String!
    private var currentDateString: String!
    private let formatter = DateFormatter()
    private let labelFormatter = DateFormatter()
    private var animator: UIViewPropertyAnimator!
    private var imagesModel = MarsImagesModel.sharedInstance
    private var currentIndex = 0
    private var totalImages = 0;
    private var multipleOn = false
    
    @IBOutlet weak var mySearchButton: UIBarButtonItem!
    @IBOutlet weak var myNavTitle: UINavigationItem!
    @IBOutlet weak var myMultipleButton: UIBarButtonItem!
    @IBOutlet var doubleTap: UITapGestureRecognizer!
    @IBOutlet weak var myHeartIcon: UIImageView!
    
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // format the date to valid url format
        formatter.dateFormat = "yyyy-MM-dd"
        getDate()
        
        // format the label
        labelFormatter.dateFormat = "MMMM dd, yyyy"
        
        // grab an image
        sendRequest(loading: true, left: false, right: false)
    }
    
    // sendRequest has three parameters that will indicate the reasoning for the request
    func sendRequest(loading: Bool, left: Bool, right: Bool) {
        Alamofire.request("https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos", method: .get, parameters: ["api_key": API_KEY, "earth_date": self.currentDateString!])
            .responseJSON { response in
                if let result = response.result.value {
                    let json = JSON(result)
                    
                    // Display an image if there is at least one photo for the current day
                    if !json["photos"].isEmpty {
                        
                        self.totalImages = json["photos"].count
                        if let imageURL = json["photos"][self.currentIndex]["img_src"].string {
                            let httpsURL = imageURL.replacingOccurrences(of: "http", with: "https")
                            let url = URL(string: httpsURL)

                            // Set the ImageView with an image from a URL
                            self.myImageView.kf.setImage(with: url)
                            
                            // if in the normal view, keep updating the date
                            if !self.multipleOn {
                                let tempDateFormat = self.formatter.date(from: self.currentDateString!)
                                self.myDateLabel.text = self.labelFormatter.string(from: tempDateFormat!)
                            }
                                
                            // if showing all the pictures from one day then keep updating the index
                            else {
                                self.myDateLabel.text = String(self.currentIndex + 1) + "/" + String(self.totalImages)
                            }
                            
                            // keep a copy of the latest day with photos posted
                            if(loading) {
                                self.todaysDateString = self.currentDateString
                            }
                        }
                    }
                        
                    // if the current day is empty and we are still initializing the scene, then move back a day until photos are found
                    else if (loading) {
                        self.getYesterday()
                        self.sendRequest(loading: true, left: false, right: true)
                    }
                    
//                    else if(loading && !left && right) {
//                        self.getYesterday()
//                        self.sendRequest(loading: true, left: false, right: true)
//                    }
                        
                    // get yesterday's posts
                    else if(!loading && !left && right) {
                        self.getYesterday()
                        self.sendRequest(loading: false, left: false, right: true)
                    }
                        
                    // get tomorrow's posts
                    else if(left && !right) {
                        if(self.getTomorrow()) {
                            self.sendRequest(loading: false, left: true, right: false)
                        }
                    }
                }
        }
    }
    
    // the images when swiping will depend on what the user wants to see. If the boolean multipleOn is true then swiping will
    // show the users the photos of THAT specific day. If false then, it will show the first image of everyday
    @IBAction func rightSwiped(_ sender: Any) {
        if multipleOn && currentIndex > 0{
            currentIndex -= 1
            sendRequest(loading: false, left: false, right: false)
        }
        else if !multipleOn {
            getYesterday()
            sendRequest(loading: false, left: false, right: true)
        }
    }
    
    @IBAction func leftSwiped(_ sender: Any) {
        if multipleOn && currentIndex < totalImages - 1 {
            currentIndex += 1
            sendRequest(loading: false, left: false, right: false)
        }
        else if !multipleOn {
            if (getTomorrow()){
                sendRequest(loading: false, left: true, right: false)
            }
        }
    }
    
    // gets today's date
    func getDate() {
        let date = Date()
        currentDateString = formatter.string(from: date)
    }
    
    // sets the current date as the day before the initial current
    func getYesterday() {
        var currDate = formatter.date(from: currentDateString)
        currDate = currDate?.addingTimeInterval(24 * -3600)
        currentDateString = formatter.string(from: (currDate)!)
    }
    
    // sets the current date to the day after the initial current
    func getTomorrow()-> Bool {
        let today = formatter.date(from: todaysDateString)
        var currDate = formatter.date(from: currentDateString)
        if (today != currDate) {
            currDate = currDate?.addingTimeInterval(24 * 3600)
            currentDateString = formatter.string(from: (currDate)!)
            return true
        }
        else {
            return false
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
        if segue.identifier == "selectDateSegue" {
            let dateSelectViewController = segue.destination as! DateSelectViewController
            
            // pass the values
            dateSelectViewController.currentDateString = self.currentDateString
            dateSelectViewController.todaysDateString = self.todaysDateString
    
            // call the completion handler to set up the new date
            dateSelectViewController.completionHandler = {(newDateString) in
                self.currentDateString = newDateString
                self.sendRequest(loading: false, left: true, right: false)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    // animation for the heart
    func fadeIn() {
        myHeartIcon.alpha = 1
    }
    func fadeOut() {
        myHeartIcon.alpha = 0
    }
    
    // allows user to "like" a photo which will send it to the favorites tab (aka the data model in the backend)
    @IBAction func tappedTwice(_ sender: Any) {
        if myImageView.image != nil {
            self.imagesModel.insert(url: self.currentDateString, id: self.currentIndex)
            animator = UIViewPropertyAnimator(duration: 1.1, curve: UIView.AnimationCurve.easeIn, animations: fadeIn)
            animator.startAnimation()
            
            animator.addCompletion{position in
        
                let animator2 = UIViewPropertyAnimator(duration: 0.50, curve: UIView.AnimationCurve.linear, animations: { () in
                    self.fadeOut()
                })
                animator2.startAnimation()
                print(self.imagesModel.numberOfImages())
            }
        }
    }
    
    // when the folder icon is tapped, the boolean is switched and an obvious change to the view is made to indicate a change
    @IBAction func multipleTapped(_ sender: Any) {
        multipleOn = !multipleOn
        currentIndex = 0
        if multipleOn {
            myNavTitle.title = myDateLabel.text
            myDateLabel.text = String(currentIndex + 1) + "/" + String(totalImages)
            mySearchButton.isEnabled = false
        }
        else {
            myDateLabel.text = myNavTitle.title
            myNavTitle.title = "Mars Rover"
            mySearchButton.isEnabled = true
        }
    }
}
