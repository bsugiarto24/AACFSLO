//
//  AnnouncementsController.swift
//  Scrumptious
//
//  Created by Bryan Sugiarto on 5/20/16.
//
//

import UIKit
import Firebase

class AnnouncementsController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var announcementView: UITableView!
    
    var data = [String]()
    var keys = [String]()
    var detaildate = [String]()
    var username = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.title = "Announcements"
        
        Reachability.internetCheck()
        
        //get user name
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    self.username = Reachability.parseOptional(String(result["name"]))
                    
                }
            })
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //refresh
        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/Announcemnts")
        ref.queryOrderedByChild("date").observeEventType(.ChildAdded, withBlock: { snapshot in
            if let announcement = snapshot.value["announcement"] as? String {
                let date = Reachability.parseOptional(String(snapshot.value["date"]))
                let name = Reachability.parseOptional(String(snapshot.value["author"]))
                print("\(snapshot.key) prayer this:  \(announcement)")
                self.self.data.append("\(announcement)")
                self.self.detaildate.append("by \(name) on \(date)")
                self.self.keys.append(snapshot.key)
                self.announcementView.reloadData()
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    //displays data in reverse order (newest first)
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("announcementCell", forIndexPath: indexPath)
        cell.textLabel?.text = keys[keys.count - indexPath.row - 1]
        cell.detailTextLabel?.text = data[data.count - indexPath.row - 1]
        return cell
    }
    
    
    //called when table is pulled down
    func refresh(sender:AnyObject) {
        data.removeAll()
        detaildate.removeAll()
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/Announcemnts")
        ref.queryOrderedByChild("date").observeEventType(.ChildAdded, withBlock: { snapshot in
            if let announcement = snapshot.value["announcement"] as? String {
                let date = Reachability.parseOptional(String(snapshot.value["date"]))
                let name = Reachability.parseOptional(String(snapshot.value["author"]))
                print("\(snapshot.key) announced this:  \(announcement)")
                self.self.data.append("\(announcement)")
                self.self.detaildate.append("by \(name) on \(date)")
                self.announcementView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        })
    }
    
    //delete cabailities
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if username == "Bryan Sugiarto" && editingStyle == .Delete {
            let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/Announcemnts")
            let ref3 = ref.childByAppendingPath(keys[keys.count - indexPath.row - 1])
            print("deleteing: \(ref3)")
            
            
            ref3.removeValue()
            keys.removeAtIndex(indexPath.row)
            data.removeAtIndex(indexPath.row)
            detaildate.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Delete {
            //shows an alert window if not admin
            Reachability.alertView("Invalid Action", message: "You are Not an Admin")
        }
    }

}
