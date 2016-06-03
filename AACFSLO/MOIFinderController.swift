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

    
    func refresh()
    {
        data.removeAll()
        
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
        ref.queryOrderedByChild("status").observeEventType(.ChildAdded, withBlock: { snapshot in
            let status = Reachability.parseOptional(String(snapshot.value["status"]))
            print("\(snapshot.key) - \(status)")
            self.self.data.append("\(snapshot.key) - \(status)")
            self.recTableView.reloadData()
            print(self.data)
        })
        self.refreshControl?.endRefreshing()
    }
    
    func refresh(sender:AnyObject) {
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var helloWorldTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("refresh"), userInfo: nil, repeats: true)

        //let mySelector: Selector = "toggleStatus"
        let rightNavigationBarItem = UIBarButtonItem(title: "Toggle Status", style: .Plain, target: self, action: "toggleStatus")
        
        navigationItem.rightBarButtonItem = rightNavigationBarItem
        
        if self.revealViewController() != nil {
            menuButton2.target = self.revealViewController()
            menuButton2.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //refresh
        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)

        
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
            print("\(snapshot.key) - \(status)")
            self.self.data.append("\(snapshot.key) - \(status)")
            self.recTableView.reloadData()
            
        })
        print(data)
    }
    
    
    
    func toggleStatus(){
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/MoiNow")
        let ref2 = ref.childByAppendingPath(username)
        if(username == "") {
            let alertView = UIAlertView();
            alertView.addButtonWithTitle("Ok");
            alertView.title = "You are not Logged In";
            alertView.message = "Please Log In";
            alertView.show();
            return
        }
        var individual = ["name": username, "status": "free"]
        var status = "free";
        
        if(isBusy){
            individual = ["name": username, "status": "free"]
        }else{
            individual = ["name": username, "status": "busy"]
            status = "busy"
        }
        ref2.setValue(individual);
        
        var i = 0
        while(i < data.count) {
            if(data[i].containsString(username)){
                data[i] = username + " - " + status
                break;
            }
            i+=1
        }

        isBusy = !isBusy;
        recTableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("finderCell", forIndexPath: indexPath)
        cell.textLabel?.text = data[data.count - indexPath.row - 1]
        return cell
    }
    
}

