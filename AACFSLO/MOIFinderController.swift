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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton2.target = self.revealViewController()
            menuButton2.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.title = "MOI Recommendations"
        data.removeAtIndex(0)
        keys.removeAtIndex(0)
        
        if !Reachability.isConnectedToNetwork() {
            //no internet connection
            let alertView = UIAlertView();
            alertView.addButtonWithTitle("Ok");
            alertView.title = "No Internet Connection";
            alertView.message = "Please connect to the internet";
            alertView.show();
        }
        
        //check which user is logged in
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    self.username = Reachability.parseOptional(String(result["name"]))
                    if self.username == "Bryan Sugiarto" {
                        self.navigationItem.rightBarButtonItem = self.editButtonItem()
                    }
                }
            })
        }
        
        
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/lastMoi")
        ref.queryOrderedByChild("Date").observeEventType(.ChildAdded, withBlock: { snapshot in
            var date = Reachability.parseOptional(String(snapshot.value["Date"]))
            
            //converts epoch time to date if necessary
            if(!date.containsString(".")) {
                date = Reachability.epochtoDate(Double(date)!)
            }
            
            let partner = snapshot.key
            print("\(snapshot.key) - \(date)")
            self.self.data.append("\(partner)")
            self.self.keys.append(snapshot.key);
            self.recTableView.reloadData()
            
        })
        
        print(data.count)
        print(data)
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("finderCell", forIndexPath: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    //delete cabailities
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if username == "Bryan Sugiarto" && editingStyle == .Delete {
            let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/lastMoi")
            let ref3 = ref.childByAppendingPath(keys[keys.count - indexPath.row - 1])
            print(ref3)
            
            ref3.removeValue()
            keys.removeAtIndex(keys.count - indexPath.row - 1)
            data.removeAtIndex(data.count - indexPath.row - 1)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Delete {
            //shows an alert window if not admin
            let alertView = UIAlertView();
            alertView.addButtonWithTitle("Ok");
            alertView.title = "Invalid Action";
            alertView.message = "You are Not an Admin";
            alertView.show();
        }
    }
    
}

