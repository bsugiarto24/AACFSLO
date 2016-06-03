//
//  PrayerRequestController.swift
//  Scrumptious
//
//  Created by Bryan Sugiarto on 5/17/16.
//
//

import UIKit
import Firebase

class PrayerRequestController: UIViewController, UITextViewDelegate{
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var checkBox: CheckBox!
    var _isAnonymous = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PrayerRequestController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.title = "Prayer Request"
        
        //menu stuffs
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //attach function for submitting a prayer
        submitButton.addTarget(self, action: #selector(PrayerRequestController.submitPrayer(_:)), forControlEvents: .TouchUpInside)
        
        //select all for textField
        //textField.selectAll(submitButton)
        
        textField.text = "Enter a prayer"
        textField.textColor = UIColor.lightGrayColor()
        self.textField.delegate = self;
    }
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter a prayer"
            textView.textColor = UIColor.lightGrayColor()
        }
    }

    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //submit button for prayer
    func submitPrayer(sender: UIButton!) {
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com")
        let prayerRef = ref.childByAppendingPath("prayers")
        var user = "anonymous"
        
        //date stuffs
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        let year =  String(components.year)
        let month = String(components.month)
        let day = String(components.day)
        let period = "."
        var time = year
        time += period
        time += month
        time += period
        time += day
        
        //message from text box
        let message = textField.text
        
        
        //if user is logged in
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    
                    //set username if not anonymous
                    if(!self.checkBox.isChecked) {
                        user = String(result["name"])
                        let start = user.startIndex.advancedBy(9)
                        let end = user.endIndex.advancedBy(-1)
                        user = user.substringWithRange(start..<end)
                    }
                    
                    let time2 = FirebaseServerValue.timestamp();
                    
                    //send prayer
                    let post1 = ["author": user, "prayer": message,"date": time2]
                    let post1Ref = prayerRef.childByAutoId()
                    
                    if(message == "") {
                        //no message
                        let alertView = UIAlertView();
                        alertView.addButtonWithTitle("Ok");
                        alertView.title = "Invalid Prayer";
                        alertView.message = "Please Enter a Prayer";
                        alertView.show();
                    }
                    else if(message.characters.count > 120){
                        //message too long
                        let alertView = UIAlertView();
                        alertView.addButtonWithTitle("Ok");
                        alertView.title = "Invalid Prayer";
                        alertView.message = "Your Prayer is Too Long";
                        alertView.show();
                    }
                    else if !Reachability.isConnectedToNetwork() {
                        //no internet connection
                        let alertView = UIAlertView();
                        alertView.addButtonWithTitle("Ok");
                        alertView.title = "No Internet Connection";
                        alertView.message = "Please connect to the internet";
                        alertView.show();
                    }
                    else {
                        post1Ref.setValue(post1)
                        //successful prayer
                        let alertView = UIAlertView();
                        alertView.addButtonWithTitle("Ok");
                        alertView.title = "Sent Prayer";
                        alertView.message = "Your Prayer has Been Receieved";
                        alertView.show();
                        
                        // resets text
                        self.textField.text = ""
                    }
                }
            })
        }
        //sends anonymous prayer if not logged in
        else {
            let post1 = ["author": user,
                "prayer": message,
                "date": time]
            let post1Ref = prayerRef.childByAutoId()
            if(message == "") {
                //no message
                let alertView = UIAlertView();
                alertView.addButtonWithTitle("Ok");
                alertView.title = "Invalid Prayer";
                alertView.message = "Please Enter a Prayer";
                alertView.show();
            }
            else if(message.characters.count > 200){
                //message too long
                let alertView = UIAlertView();
                alertView.addButtonWithTitle("Ok");
                alertView.title = "Invalid Prayer";
                alertView.message = "Your Prayer is Too Long";
                alertView.show();
            }
            else if !Reachability.isConnectedToNetwork() {
                //no internet connection
                let alertView = UIAlertView();
                alertView.addButtonWithTitle("Ok");
                alertView.title = "No Internet Connection";
                alertView.message = "Please connect to the internet";
                alertView.show();
            }
            else {
                post1Ref.setValue(post1)

                //successful prayer
                let alertView = UIAlertView();
                alertView.addButtonWithTitle("Ok");
                alertView.title = "Sent Prayer";
                alertView.message = "Your Prayer has Been Receieved";
                alertView.show();
                
                // resets text
                self.textField.text = ""
            }
        }
        
    }
    
}
