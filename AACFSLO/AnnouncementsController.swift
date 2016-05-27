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
        
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/Announcemnts")
        ref.queryOrderedByChild("date").observeEventType(.ChildAdded, withBlock: { snapshot in
            if let prayer = snapshot.value["announcement"] as? String {
                let date = self.parseOptional(String(snapshot.value["date"]))
                let name = self.parseOptional(String(snapshot.value["author"]))
                print("\(snapshot.key) prayer this:  \(prayer)")
                self.self.data.append("\(prayer) \r\nby \(name) on \(date)")
                self.announcementView.reloadData()
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("announcementCell", forIndexPath: indexPath)
        cell.textLabel?.text = data[data.count - indexPath.row - 1]
        return cell
    }
    
    func parseOptional(str : String) ->String{
        if(str.containsString("Optional(")) {
            return str.substringWithRange(str.startIndex.advancedBy(9)..<str.endIndex.advancedBy(-1))
        }
        return str
    }

}
