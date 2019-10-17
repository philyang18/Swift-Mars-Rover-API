//
//  DateSelectViewController.swift
//  final_project
//
//  Created by Phillip Yang on 4/24/19.
//  Copyright © 2019 Phillip Yang. All rights reserved.
//

import UIKit

class DateSelectViewController: UIViewController {

    var currentDateString: String!
    var todaysDateString: String!
    var completionHandler: ((_ newDate: String)->Void)?
    
    
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var myCancelButton: UIBarButtonItem!
    @IBOutlet weak var myDoneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        minMaxDate()
        setDate()
    }
    
    // minimum date is set to when the rover landed in Mars. Do not want to let user go beyond that
    // max date is the date with the latest post
    func minMaxDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        myDatePicker.minimumDate = formatter.date(from: "2012-08-12")
        myDatePicker.maximumDate = formatter.date(from: todaysDateString)!
    }
    
    // apply current dates to the label and picker
    func setDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        myDateLabel.text = currentDateString
        myDatePicker.setDate(formatter.date(from: currentDateString)!, animated: true)
    }
    
    // acts as a listener for the date picker. Will update the label when the picker is changed
    @IBAction func datePickerValueChanged(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStringValue = formatter.string(from: myDatePicker.date)
        myDateLabel.text = dateStringValue
    }
    
    // exit the date picker view
    @IBAction func tappedCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // send the information back to the MarsViewController
    @IBAction func tappedDone(_ sender: Any) {
        completionHandler?(self.myDateLabel.text ?? currentDateString)
    }
    
}
