//
//  ToDoController2.swift
//  Scrumptious
//
//  Created by Bryan Sugiarto on 5/17/16.
//
//

import UIKit
import Firebase

class DisplayPrayerController: UITableViewController, UITextViewDelegate {
    
 
    @IBOutlet weak var checkbox: CheckBox!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet var prayerTableView: UITableView!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var toggle: UIBarButtonItem!
    
    
    
    var data = [String]()
    var filtered = [String]()
    
    var datadate = [String]()
    var filtereddate = [String]()
    
    var keys = [String]()
    var useFiltered = false
    var username = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /**** send prayer stuff ****/
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DisplayPrayerController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //attach function for submitting a prayer
        submit.addTarget(self, action: #selector(DisplayPrayerController.submitPrayer(_:)), forControlEvents: .TouchUpInside)
        
        toggle.action = #selector(DisplayPrayerController.toggle(_:))
        
    

        
        textField.text = "Enter a prayer"
        textField.textColor = UIColor.lightGrayColor()
        self.textField.delegate = self;
        /****** end of send prayer stuff */
        
        
        
        
        //refresh
        self.refreshControl?.addTarget(self, action: #selector(DisplayPrayerController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        //menu
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //set up
        self.title = "All Prayer Requests"
        Reachability.internetCheck()
    
        
        //if user is logged in
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    self.username = Reachability.parseOptional(String(result["name"]))
                    let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/prayers")
                    ref.queryOrderedByChild("date").observeEventType(.ChildAdded, withBlock: { snapshot in
                        if let prayer = snapshot.value["prayer"] as? String {
                            var date = Reachability.parseOptional(String(snapshot.value["date"]))
                            
                            if(!date.containsString(".")) {
                                date = Reachability.epochtoDate(Double(date)!)
                            }

                            let name = Reachability.parseOptional(String(snapshot.value["author"]))
                            print("\(snapshot.key) prayer:  \(prayer)")
                            self.self.data.append("\(prayer)")
                            self.self.datadate.append("\(name) on \(date)")
                            self.self.keys.append(snapshot.key)
                            
                            //add to filtered if prayer is own prayer
                            if(name == Reachability.parseOptional(String(result["name"]))) {
                                self.self.filtered.append("\(prayer)")
                                self.self.filtereddate.append("\(name) on \(date)")
                            }
                            self.prayerTableView.reloadData()
                        }
                    })
                    print(self.data)
                }
            })
        }
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
        
        let time2 = FirebaseServerValue.timestamp();
        
        //message from text box
        let message = textField.text
        
        
        //if user is logged in
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    
                    //set username if not anonymous
                    if(!self.checkbox.isChecked) {
                        user = String(result["name"])
                        let start = user.startIndex.advancedBy(9)
                        let end = user.endIndex.advancedBy(-1)
                        user = user.substringWithRange(start..<end)
                    }
                    
                    
                    //send prayer
                    let post1 = ["author": user, "prayer": message,"date": time2]
                    let post1Ref = prayerRef.childByAutoId()
                    
                    if(message == "" || message == "Enter a prayer") {
                        //no message
                        Reachability.alertView("Invalid Prayer", message: "Please Enter a Prayer")
                    }
                    else if(message.characters.count > 200){
                        //message too long
                        Reachability.alertView("Invalid Prayer", message: "Your Prayer is Too Long")
                    }
                    else if !Reachability.isConnectedToNetwork() {
                        //no internet connection
                        Reachability.alertView("No Internet Connection",
                            message: "Please connect to the internet")
                    }
                    else {
                        post1Ref.setValue(post1)
                        //successful prayer
                        Reachability.alertView("Sent Prayer",
                            message: "Your Prayer has Been Receieved")
                        self.prayerTableView.reloadData()
                        
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
                         "date": time2]
            let post1Ref = prayerRef.childByAutoId()
            if(message == "" || message == "Enter a prayer") {
                //no message
                Reachability.alertView("Invalid Prayer", message: "Please Enter a Prayer")
            }
            else if(message.characters.count > 200){
                //message too long
                Reachability.alertView("Invalid Prayer", message: "Your Prayer is Too Long")
            }
            else if !Reachability.isConnectedToNetwork() {
                //no internet connection
                Reachability.alertView("No Internet Connection",
                                       message: "Please connect to the internet")
            }
            else {
                post1Ref.setValue(post1)
                //successful prayer
                Reachability.alertView("Sent Prayer",
                                       message: "Your Prayer has Been Receieved")
                self.prayerTableView.reloadData()
                // resets text
                self.textField.text = ""
            }
        }
    }
    

    /***** display prayer stuff *******/
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(useFiltered){
            return filtered.count
        }
        return data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath)
        if(useFiltered) {
            cell.textLabel?.text = filtered[filtered.count - indexPath.row - 1]
            cell.detailTextLabel?.text = filtereddate[filtereddate.count - indexPath.row - 1]
        }else {
            cell.textLabel?.text = data[data.count - indexPath.row - 1]
            cell.detailTextLabel?.text = datadate[datadate.count - indexPath.row - 1]
        }
        return cell
    }

    //toggles prayers
    @IBAction func toggle(sender: AnyObject) {
        useFiltered = !useFiltered
        if(useFiltered) {
            self.title = "Personal Prayer Requests"
        }else{
            self.title = "All Prayer Requests"
        }
        prayerTableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if useFiltered && editingStyle == .Delete {
            
            //remove prayer from data
            let message = filtered[filtered.count - indexPath.row - 1]
            var index = 0
            for str in data {
                if(message == str){
                    data.removeAtIndex(index)
                    datadate.removeAtIndex(index)
                    break
                }
                index+=1
            }
            print(index); print(data); print(keys)
            
            //remove from database
            let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/prayers")
            let ref2 = ref.childByAppendingPath(keys[index])
            print(ref2)
            ref2.removeValue()
            
            //remove key from array
            keys.removeAtIndex(index)
            
            //remove prayer from filtered
            filtered.removeAtIndex(filtered.count - indexPath.row - 1)
            filtereddate.removeAtIndex(filtereddate.count - indexPath.row - 1)
            
            //remove from row
            prayerTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        
        //removing prayer from all prayer table as admin
        else if !useFiltered && username == "Bryan Sugiarto" && editingStyle == .Delete {
            let message = data[data.count - indexPath.row - 1]
            var index = 0
            for str in data {
                if(message == str){
                    data.removeAtIndex(index)
                    datadate.removeAtIndex(index)
                    var index2 = 0
                    for str2 in filtered {
                        if(message == str2){
                            filtered.removeAtIndex(index2)
                            filtereddate.removeAtIndex(index2)
                            break
                        }
                        index2+=1
                    } 
                    break
                }
                index+=1
            }
            print(index)
            print(data)
            print(keys)
            
            //remove from database
            let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/prayers")
            let ref2 = ref.childByAppendingPath(keys[index])
            print(ref2)
            ref2.removeValue()
            
            //remove key from array
            keys.removeAtIndex(index)
            
            //remove from row
            prayerTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        //remove prayer that is not authorized
        else if !useFiltered && editingStyle == .Delete {
                Reachability.alertView("Invalid Access", message: "Please Toggle to Delete Prayer")
        }
    }
    
    
    //called when table is pulled down
    func refresh(sender:AnyObject) {
        
        print("refresh")
        
        data.removeAll()
        keys.removeAll()
        datadate.removeAll()
        filtereddate.removeAll()
        filtered.removeAll()
        
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    self.username = Reachability.parseOptional(String(result["name"]))
                    let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/prayers")
                    ref.queryOrderedByChild("date").observeEventType(.ChildAdded, withBlock: { snapshot in
                        if let prayer = snapshot.value["prayer"] as? String {
                            var date = Reachability.parseOptional(String(snapshot.value["date"]))
                            
                            if(!date.containsString(".")) {
                                date = Reachability.epochtoDate(Double(date)!)
                            }
                            
                            let name = Reachability.parseOptional(String(snapshot.value["author"]))
                            print("\(snapshot.key) prayer:  \(prayer)")
                            self.self.data.append("\(prayer)")
                            self.self.datadate.append("\(name) on \(date)")
                            self.self.keys.append(snapshot.key)
                            
                            //add to filtered if prayer is own prayer
                            if(name == Reachability.parseOptional(String(result["name"]))) {
                                self.self.filtered.append("\(prayer)")
                                self.self.filtereddate.append("\(name) on \(date)")
                            }
                        }
                        self.prayerTableView.reloadData()
                    })
                    print(self.data)
                    self.refreshControl?.endRefreshing()
                }
            })
        }
    }
    
}

