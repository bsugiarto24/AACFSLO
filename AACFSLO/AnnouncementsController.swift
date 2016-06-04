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
    
    var data = ["data"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.title = "Announcements"
        data.removeAtIndex(0)
        
        Reachability.internetCheck()
        
        //refresh
        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/Announcemnts")
        ref.queryOrderedByChild("date").observeEventType(.ChildAdded, withBlock: { snapshot in
            if let prayer = snapshot.value["announcement"] as? String {
                let date = Reachability.parseOptional(String(snapshot.value["date"]))
                let name = Reachability.parseOptional(String(snapshot.value["author"]))
                print("\(snapshot.key) prayer this:  \(prayer)")
                self.self.data.append("\(prayer) \r\nby \(name) on \(date)")
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
        cell.textLabel?.text = data[data.count - indexPath.row - 1]
        return cell
    }
    
    
    //called when table is pulled down
    func refresh(sender:AnyObject) {
        data.removeAll()
        
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/Announcemnts")
        ref.queryOrderedByChild("date").observeEventType(.ChildAdded, withBlock: { snapshot in
            if let announcement = snapshot.value["announcement"] as? String {
                let date = Reachability.parseOptional(String(snapshot.value["date"]))
                let name = Reachability.parseOptional(String(snapshot.value["author"]))
                print("\(snapshot.key) announced this:  \(announcement)")
                self.self.data.append("\(announcement) \r\nby \(name) on \(date)")
                self.announcementView.reloadData()
                 self.refreshControl?.endRefreshing()
            }
        })
    }

}
