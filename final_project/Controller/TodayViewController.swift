//
//  TodayViewController.swift
//  final_project
//
//  Created by Phillip Yang on 4/30/19.
//  Copyright © 2019 Phillip Yang. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SwiftyJSON


let API_KEY = "RzyT98G4RWi51f3LYNHdbdEzUJkUH7RdAJnQoOd0"


class TodayViewController: UIViewController {

    // variables
    var todaysDateString: String!
    var currentDateString: String!
    let formatter = DateFormatter()
    let labelFormatter = DateFormatter()
    var animator: UIViewPropertyAnimator!
    var imagesModel = MarsImagesModel.sharedInstance
    private var currentIndex = 0
    private var maxIndex = 0
    
    @IBOutlet weak var myTotalLabel: UILabel!
    @IBOutlet weak var myHeartIcon: UIImageView!
    @IBOutlet weak var myImageView: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // format the date so it works with API
        formatter.dateFormat = "yyyy-MM-dd"
        
        // call getDate() to set up today's date
        getDate()
        
        // formatting label so it doesn't have all numbers
        labelFormatter.dateFormat = "MMMM dd, yyyy"
        
        // grab a photo
        sendRequest()
    }
    
    // grabs today's set of photos. If they are not posted then grab yesterday's. Guaranteed a photo
    func sendRequest() {
        Alamofire.request("https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos", method: .get, parameters: ["api_key": API_KEY, "earth_date": self.currentDateString!])
            .responseJSON { response in
                
                if let result = response.result.value {
                    let json = JSON(result)
                    
                    // If the response has an array of photos
                    if !json["photos"].isEmpty && self.currentIndex < json["photos"].count {
                        
                        self.maxIndex = json["photos"].count - 1
                        
                        if let imageURL = json["photos"][self.currentIndex]["img_src"].string {
                            let httpsURL = imageURL.replacingOccurrences(of: "http", with: "https")
                            let url = URL(string: httpsURL)
                            
                            // Set the ImageView with an image from a URL
                            self.myImageView.kf.setImage(with: url)
                            
                            // set today as the current (which is the latest date) so I have a limit on swiping left
                            self.todaysDateString = self.currentDateString
                            
                            // set up how many photos there are for today and which photo the user is looking at
                            self.myTotalLabel.text = String(self.currentIndex + 1) + "/"  + String(json["photos"].count)
                        }
                    }
                        
                    // repeated go back 24 hrs until an array of photos is found
                    else {
                        self.getYesterday()
                        self.sendRequest()
                    }
                }
        }
    }
    
    // show the previous image
    @IBAction func rightSwiped(_ sender: Any) {
        if currentIndex > 0 {
            currentIndex -= 1
            sendRequest()
        }
    }
    
    // show the next image
    @IBAction func leftSwiped(_ sender: Any) {
        if currentIndex < maxIndex {
            currentIndex += 1
            sendRequest()
        }
    }
    
    // grab today's date
    func getDate() {
        let date = Date()
        currentDateString = formatter.string(from: date)
    }
    
    
    // get yesterday's date and set that as the current date
    func getYesterday() {
        var currDate = formatter.date(from: currentDateString)
        currDate = currDate?.addingTimeInterval(24 * -3600)
        currentDateString = formatter.string(from: (currDate)!)
    }
 
    // animation for the "like" button
    func fadeIn() {
        myHeartIcon.alpha = 1
    }
    func fadeOut() {
        myHeartIcon.alpha = 0
    }
    
    // "like" function that will add the image's url and index to the singleton model
    @IBAction func tappedTwice(_ sender: Any) {
        
        // do not allow double tapping if image is loading
        if myImageView.image != nil {
            
            // add the image
            self.imagesModel.insert(url: self.currentDateString, id: self.currentIndex)
            
            //animate the heart to symbolize that the user has "favorited" the image
            animator = UIViewPropertyAnimator(duration: 1.1, curve: UIView.AnimationCurve.easeIn, animations: fadeIn)
            animator.startAnimation()
            
            animator.addCompletion{position in
                
                let animator2 = UIViewPropertyAnimator(duration: 0.50, curve: UIView.AnimationCurve.linear, animations: { () in
                    self.fadeOut()
                })
                animator2.startAnimation()
            }
        }
    }
}
