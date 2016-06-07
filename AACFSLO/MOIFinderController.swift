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
    var time = 300.0
    var alert = UIAlertController(title: "Enter Location and Time", message: "Time is in minutes", preferredStyle: .Alert)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //refresh timer
        let refreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(MOIFinderController.refresh as (MOIFinderController) -> () -> ()), userInfo: nil, repeats: true)

        //toggle button
        let rightNavigationBarItem = UIBarButtonItem(title: "Toggle", style: .Plain, target: self, action: #selector(MOIFinderController.toggleStatus))
        navigationItem.rightBarButtonItem = rightNavigationBarItem
        
        
        //Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
            textField.placeholder = "Location"
        })
        
        //Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
            textField.placeholder = "Time"
            textField.keyboardType = .NumberPad
        })
        
        //Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = self.alert.textFields![0] as UITextField
            let textField2 = self.alert.textFields![1] as UITextField
            print("Text field: \(textField.text)")
            self.location = textField.text!
            
            
            self.time = Double(textField2.text!)! * 60
            self.finishToggle()
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
        Reachability.internetCheck()
        

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
            print(self.data)
        })
        self.refreshControl?.endRefreshing()
    }
    
    //called when table is pulled down
    func refresh(sender:AnyObject) {
        refresh()
    }
    
    
    //when user clicks on toggle status
    func toggleStatus(){
        print("toggle status")
        
        
        //add user to list
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    let name = Reachability.parseOptional(String(result["name"]))
                    let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
                    let ref2 = ref.childByAppendingPath(name)
                    let data = ["name": name, "status": "busy"]
                    self.username = name
                    
                    //check if user is already there
                    var hasUser = false
                    var index = 0
                    while(index < self.keys.count){
                        if self.keys[index] == name{
                            hasUser = true
                            if(self.data.contains("free")){
                                self.isBusy = false
                            }
                            break
                        }
                        index += 1
                    }
                    
                    if(!hasUser){
                        ref2.setValue(data)
                        self.isBusy = true;
                    }
                    self.recTableView.reloadData()
                }
            })
        }

        
        //if free then ask for location
        if(isBusy){
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            finishToggle()
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
            var timeInterval = NSDate().timeIntervalSince1970
            timeInterval += self.time * 60
            let str = Reachability.epochtoTime(timeInterval)
            let loc2 = location + " until " + str
            
            individual = ["name": username, "status": "free", "location": loc2]
            //set logout timer
            let logoutTimer = NSTimer.scheduledTimerWithTimeInterval(60 * self.time, target: self, selector: #selector(MOIFinderController.logout as (MOIFinderController) -> () -> ()), userInfo: nil, repeats: true)
        }else{
            individual = ["name": username, "status": "busy"]
            status = "busy"
        }
        ref2.setValue(individual);
        isBusy = !isBusy;
        
        //toggles status on tableview
        var i = 0
        while(i < data.count) {
            if(data[i].containsString(username)){
                if(!isBusy){
                    print("adding location")
                    data[i] = username + " - " + status + " at " + location
                }else{
                    data[i] = username + " - " + status
                }
                break;
            }
            i+=1
        }
        recTableView.reloadData()
    }
    
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

