//
//  SuggestionController.swift
//  Scrumptious
//
//  Created by Bryan Sugiarto on 5/17/16.
//
//

import UIKit
import Firebase

class SuggestionController: UIViewController, UITextViewDelegate{
    
    ///@IBOutlet weak var submitButton: UIButton!
    //@IBOutlet weak var textField: UITextView!
    //@IBOutlet weak var checkBox2: CheckBox!

    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    @IBOutlet weak var checkBox: CheckBox!

    var _isAnonymous = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PrayerRequestController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.title = "Suggestions to Leadership"
        
        //menu stuffs
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //attach function for submitting a prayer
        submitButton.addTarget(self, action: #selector(self.submitPrayer(_:)), forControlEvents: .TouchUpInside)

        textField.text = "Enter a Suggestion"
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
            textView.text = "Enter a Suggestion"
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
        let prayerRef = ref.childByAppendingPath("suggestions")
        var user = "anonymous"
        
        
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
                    
                    if(message == "" || message == "Enter a Suggestion") {
                        //no message
                        Reachability.alertView("Invalid Suggestion", message: "Please Enter a Suggestion")
                    }
                    else if(message.characters.count > 200){
                        //message too long
                        Reachability.alertView("Invalid Suggestion", message: "Your Suggestion is Too Long")
                    }
                    else if !Reachability.isConnectedToNetwork() {
                        //no internet connection
                        Reachability.alertView("No Internet Connection",
                            message: "Please connect to the internet")
                    }
                    else {
                        post1Ref.setValue(post1)
                        //successful prayer
                        Reachability.alertView("Sent Suggestion",
                            message: "Your Suggestion has Been Receieved")
                        
                        // resets text
                        self.textField.text = ""
                    }
                }
            })
        }
            //sends anonymous prayer if not logged in
        else {
            let time2 = FirebaseServerValue.timestamp();
            let post1 = ["author": user,
                         "prayer": message,
                         "date": time2]
            let post1Ref = prayerRef.childByAutoId()
            if(message == "" || message == "Enter a Suggestion") {
                //no message
                Reachability.alertView("Invalid Suggestion", message: "Please Enter a Suggestion")
            }
            else if(message.characters.count > 200){
                //message too long
                Reachability.alertView("Invalid Suggestion", message: "Your Suggestion is Too Long")
            }
            else if !Reachability.isConnectedToNetwork() {
                //no internet connection
                Reachability.alertView("No Internet Connection",
                                       message: "Please connect to the internet")
            }
            else {
                post1Ref.setValue(post1)
                //successful prayer
                Reachability.alertView("Sent Suggestion",
                                       message: "Your Suggestion has Been Receieved")
                
                // resets text
                self.textField.text = ""
            }
        }
        
    }
    
}
