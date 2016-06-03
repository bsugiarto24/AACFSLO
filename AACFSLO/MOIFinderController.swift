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
    var username = ""
    var isBusy = true
    var location =  ""
    var alert = UIAlertController(title: "Enter Location", message: "", preferredStyle: .Alert)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //timer
        var helloWorldTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(MOIFinderController.refresh as (MOIFinderController) -> () -> ()), userInfo: nil, repeats: true)

        //toggle button
        let rightNavigationBarItem = UIBarButtonItem(title: "Toggle", style: .Plain, target: self, action: #selector(MOIFinderController.toggleStatus))
        navigationItem.rightBarButtonItem = rightNavigationBarItem
        
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
            textField.placeholder = "Location"
        })
        
        //Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = self.alert.textFields![0] as UITextField
            print("Text field: \(textField.text)")
            self.location = textField.text!
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
        
        
        //get list of people
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
        ref.queryOrderedByChild("status").observeEventType(.ChildAdded, withBlock: { snapshot in
            let status = Reachability.parseOptional(String(snapshot.value["status"]))
            let loc = Reachability.parseOptional(String(snapshot.value["location"]))
            
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
        
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
        ref.queryOrderedByChild("status").observeEventType(.ChildAdded, withBlock: { snapshot in
            let status = Reachability.parseOptional(String(snapshot.value["status"]))
            let loc = Reachability.parseOptional(String(snapshot.value["location"]))
            
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
            individual = ["name": username, "status": "free", "location": location]
        }else{
            individual = ["name": username, "status": "busy"]
            status = "busy"
        }
        ref2.setValue(individual);
        
        isBusy = !isBusy;
        
        //change status on tableview
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
    
}

