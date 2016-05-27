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
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "MOI History"
        data.removeAtIndex(0)
        keys.removeAtIndex(0)
        
        
        
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    self.user = self.parseOptional(String(result["name"]))
                    let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/users")
                    let ref2 = ref.childByAppendingPath(self.parseOptional(String(result["name"])))
                    ref2.queryOrderedByChild("Date").observeEventType(.ChildAdded, withBlock: { snapshot in
                        if let partner = snapshot.value["Partner"] as? String {
                            let date = self.parseOptional(String(snapshot.value["Date"]))
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
            //shows an alert window
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
    
    func parseOptional(str : String) ->String{
        if(str.containsString("Optional(")) {
            return str.substringWithRange(str.startIndex.advancedBy(9)..<str.endIndex.advancedBy(-1))
        }
        return str
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/users")
            let ref2 = ref.childByAppendingPath(user)
            let ref3 = ref2.childByAppendingPath(keys[indexPath.row])
            print(ref3)
            
            ref3.removeValue()
            keys.removeAtIndex(indexPath.row)
            data.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
