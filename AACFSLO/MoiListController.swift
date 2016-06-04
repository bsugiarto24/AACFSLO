//
//  ToDoController2.swift
//  Scrumptious
//
//  Created by Bryan Sugiarto on 5/17/16.
//
//

import UIKit
import Firebase

class MoiListController: UITableViewController {
    
    @IBOutlet var moiTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var data = ["data"]
    var keys = ["data"]
    var user = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reveal view controller
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "MOI History"
        data.removeAtIndex(0)
        keys.removeAtIndex(0)
        Reachability.internetCheck()
        
        //refresh
        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        //check FB login
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    self.user = Reachability.parseOptional(String(result["name"]))
                    let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/users")
                    let ref2 = ref.childByAppendingPath(Reachability.parseOptional(String(result["name"])))
                    
                    //query user's Moi's
                    ref2.queryOrderedByChild("Date").observeEventType(.ChildAdded, withBlock: { snapshot in
                        if let partner = snapshot.value["Partner"] as? String {
                            var date = Reachability.parseOptional(String(snapshot.value["Date"]))
                            
                            //converts epoch time to date if necessary
                            if(!date.containsString(".")) {
                                date = Reachability.epochtoDate(Double(date)!)
                            }
                            
                            print("\(snapshot.key) prayer this:  \(partner)")
                            self.self.data.append("\(partner) on \(date)")
                            self.self.keys.append(snapshot.key)
                            self.moiTableView.reloadData()
                        }
                    })
                    print(self.self.data.count)
                    print(self.self.data)
                }
            })
        }else {
            //shows an alert window if not logged in
            let alertView = UIAlertView();
            alertView.addButtonWithTitle("Ok");
            alertView.title = "You are not Logged In";
            alertView.message = "Please Log In";
            alertView.show();
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MoiCell", forIndexPath: indexPath)
        cell.textLabel?.text = data[data.count - indexPath.row - 1]
        return cell
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/users")
            let ref2 = ref.childByAppendingPath(user)
            let ref3 = ref2.childByAppendingPath(keys[keys.count - indexPath.row - 1])
            print(ref3)
            
            ref3.removeValue()
            keys.removeAtIndex(keys.count - indexPath.row - 1)
            data.removeAtIndex(data.count - indexPath.row - 1)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    //called when table is pulled down
    func refresh(sender:AnyObject) {
        data.removeAll()
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    self.user = Reachability.parseOptional(String(result["name"]))
                    let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/users")
                    let ref2 = ref.childByAppendingPath(Reachability.parseOptional(String(result["name"])))
                    
                    //query user's Moi's
                    ref2.queryOrderedByChild("Date").observeEventType(.ChildAdded, withBlock: { snapshot in
                        if let partner = snapshot.value["Partner"] as? String {
                            var date = Reachability.parseOptional(String(snapshot.value["Date"]))
                            
                            //converts epoch time to date if necessary
                            if(!date.containsString(".")) {
                                date = Reachability.epochtoDate(Double(date)!)
                            }
                            
                            print("\(snapshot.key) prayer this:  \(partner)")
                            self.self.data.append("\(partner) on \(date)")
                            self.self.keys.append(snapshot.key)
                            self.moiTableView.reloadData()
                        }
                    })
                    print(self.self.data.count)
                    print(self.self.data)
                }
            })
        }else {
            //shows an alert window if not logged in
            let alertView = UIAlertView();
            alertView.addButtonWithTitle("Ok");
            alertView.title = "You are not Logged In";
            alertView.message = "Please Log In";
            alertView.show();
        }
        self.refreshControl?.endRefreshing()
    }
}

