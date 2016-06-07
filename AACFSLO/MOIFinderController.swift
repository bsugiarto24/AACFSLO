//
//  ToDoController2.swift
//  Scrumptious
//
//  Created by Bryan Sugiarto on 5/17/16.
//
//

import UIKit
import Firebase

class MOIFinderController: UITableViewController {
    @IBOutlet var recTableView: UITableView!
    @IBOutlet weak var menuButton2: UIBarButtonItem!
    var data = ["data"]
    var keys = ["data"]
    var username = ""
    var isBusy = true
    var location =  ""
    var timeStr = ""
    var time = 300.0
    var alert = UIAlertController(title: "Enter Location and Time", message: "", preferredStyle: .Alert)
    var rightNavigationBarItem = UIBarButtonItem.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //refresh timer
        let refreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(MOIFinderController.refresh as (MOIFinderController) -> () -> ()), userInfo: nil, repeats: true)
        
        //toggle button
        rightNavigationBarItem = UIBarButtonItem(title: "Toggle", style: .Plain, target: self, action: #selector(MOIFinderController.toggleStatus))
        navigationItem.rightBarButtonItem = rightNavigationBarItem
        
        
        //Congigure Alert Text Field
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
            textField.placeholder = "Location"
        })
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
            textField.placeholder = "Time (in minutes)"
            textField.keyboardType = .NumberPad
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = self.alert.textFields![0] as UITextField
            let textField2 = self.alert.textFields![1] as UITextField
            print("Text field: \(textField.text)")
            self.location = textField.text!
            
            
            if(textField2.text == nil || textField2.text == ""){
                Reachability.alertView("Invalid Input", message: "Enter a Number")
            }else{
                self.time = Double(textField2.text!)! * 60
                self.finishToggle()
            }
        }))

        
        //menu button
        if self.revealViewController() != nil {
            menuButton2.target = self.revealViewController()
            menuButton2.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //refresh
        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)

        //set up
        self.title = "MOI Finder"
        data.removeAtIndex(0)
        keys.removeAtIndex(0)
        Reachability.internetCheck()
        
        //get user name
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    self.username = Reachability.parseOptional(String(result["name"]))
                }
            })
        }
        
        //get list of people
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
        ref.queryOrderedByChild("status").observeEventType(.ChildAdded, withBlock: { snapshot in
            let status = Reachability.parseOptional(String(snapshot.value["status"]))
            let loc = Reachability.parseOptional(String(snapshot.value["location"]))
            
            self.self.keys.append(snapshot.key)
            if(status == "free"){
                self.self.data.append("\(snapshot.key) - \(status) at \(loc)")
            }else{
                self.self.data.append("\(snapshot.key) - \(status)")
            }
            self.recTableView.reloadData()
        })
        print(data)
    }
    
    
    
    // refreshes the data in tableview
    func refresh(){
        print("refresh")
        print(username)
        data.removeAll()
        keys.removeAll()
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
        ref.queryOrderedByChild("status").observeEventType(.ChildAdded, withBlock: { snapshot in
            let status = Reachability.parseOptional(String(snapshot.value["status"]))
            let loc = Reachability.parseOptional(String(snapshot.value["location"]))
            self.self.keys.append(snapshot.key)
            
            if(status == "free"){
                self.self.data.append("\(snapshot.key) - \(status) at \(loc)")
            }else{
                self.self.data.append("\(snapshot.key) - \(status)")
            }
            
            self.recTableView.reloadData()
        })
        self.refreshControl?.endRefreshing()
        print(self.data)
    }
    
    //called when table is pulled down
    func refresh(sender:AnyObject) {
        refresh()
    }
    
    
    //when user clicks on toggle status
    func toggleStatus(){
        print("toggle status")
        print("is busy: " + String(isBusy))
        
        
        //add user to list
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    let name = Reachability.parseOptional(String(result["name"]))
                    let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
                    let ref2 = ref.childByAppendingPath(name)
                    let insert = ["name": name, "status": "busy"]
                    
                    //check if user is already there
                    var hasUser = false
                    var index = 0
                    
                    print(self.data)
                    print(self.keys)
                    
                    while(index < self.keys.count){
                        if self.keys[index] == name{
                            hasUser = true
                            print("found user")
                            if(self.data[index].containsString("free")){
                                self.isBusy = false
                            }else{
                                self.isBusy = true
                            }
                            break
                        }
                        index += 1
                    }
                    
                    //insert user if not there already
                    if(!hasUser){
                        ref2.setValue(insert)
                        self.isBusy = true;
                    }
                    
                    //if free then ask for location
                    if(self.isBusy){
                        self.presentViewController(self.alert, animated: true, completion: nil)
                    }else{
                        self.finishToggle()
                    }
                    
                    self.recTableView.reloadData()
                }
            })
        }
    }
    
    
    
    
    func finishToggle() {
        print("finish toggle")
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
        let ref2 = ref.childByAppendingPath(username)
        
        //check if logged in
        if(username == "") {
            let alertView = UIAlertView();
            alertView.addButtonWithTitle("Ok");
            alertView.title = "You are not Logged In";
            alertView.message = "Please Log In";
            alertView.show();
            return
        }
        
        //toggle data in database
        var individual = ["name": username]
        var status = "free";
        if(isBusy){
            let startDate = NSDate()
            print(startDate)
            let date = startDate.dateByAddingTimeInterval(self.time)
            
            print(date);
            
            timeStr = Reachability.epochtoTime(date.timeIntervalSince1970)
            let loc2 = location + " until " + timeStr
            
            individual = ["name": username, "status": "free", "location": loc2]
            //set logout timer
            let busyTimer = NSTimer.scheduledTimerWithTimeInterval(60 * self.time, target: self, selector: #selector(MOIFinderController.logout as (MOIFinderController) -> () -> ()), userInfo: nil, repeats: true)
            
            isBusy = false
        }else{
            individual = ["name": username, "status": "busy"]
            status = "busy"
            isBusy = true
        }
        ref2.setValue(individual);
        
        //toggles status on tableview*
        var i = 0
        while(i < data.count) {
            if(data[i].containsString(username)){
                if(!isBusy){
                    print("adding location")
                    data[i] = username + " - " + status + " at " + location + " until " + timeStr
                }else{
                    data[i] = username + " - " + status
                }
                break;
            }
            i+=1
        }
        recTableView.reloadData()
    }
    
    
    // table view functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("finderCell", forIndexPath: indexPath)
        cell.textLabel?.text = data[data.count - indexPath.row - 1]
        let str = data[data.count - indexPath.row - 1]
        if(str.containsString("free")){
            cell.backgroundColor = UIColor.greenColor()
        }else {
            cell.backgroundColor = UIColor.redColor()
        }
        return cell
    }
    
    //delete cabailities
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if username == "Bryan Sugiarto" && editingStyle == .Delete {
            let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
            let ref3 = ref.childByAppendingPath(keys[keys.count - indexPath.row - 1])
            print(ref3)
            
            ref3.removeValue()
            keys.removeAtIndex(keys.count - indexPath.row - 1)
            data.removeAtIndex(data.count - indexPath.row - 1)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        else if editingStyle == .Delete {
            Reachability.alertView("Invalid Action", message: "You are Not an Admin")
        }
    }
    
    
    //function when user is busy from time
    func logout() {
        //add user to list
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    let name = Reachability.parseOptional(String(result["name"]))
                    let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
                    let ref2 = ref.childByAppendingPath(name)
                    let data = ["name": name, "status": "busy"]
                    self.username = name
                    ref2.setValue(data)
                    self.isBusy = true;
                    self.recTableView.reloadData()
                }
            })
        }
    }
    
    
}

