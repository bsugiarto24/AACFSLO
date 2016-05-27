//
//  ToDoController2.swift
//  Scrumptious
//
//  Created by Bryan Sugiarto on 5/17/16.
//
//

import UIKit
import Firebase

class MOIRecommendationController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var recTableView: UITableView!
    var data = ["data"]
    var data2 = ["data2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.title = "MOI Recommendations"
        data.removeAtIndex(0)
        
        let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/lastMoi")
        ref.queryOrderedByChild("Date").observeEventType(.ChildAdded, withBlock: { snapshot in
            let date = self.parseOptional(String(snapshot.value["Date"]))
            let partner = snapshot.key
            print("\(snapshot.key) - \(date)")
            self.self.data.append("\(partner)")
            self.recTableView.reloadData()
            
        })

        print(data.count)
        print(data)
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recCell", forIndexPath: indexPath)
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

