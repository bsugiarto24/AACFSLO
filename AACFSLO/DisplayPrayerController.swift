//
//  ToDoController2.swift
//  Scrumptious
//
//  Created by Bryan Sugiarto on 5/17/16.
//
//

import UIKit
import Firebase

class DisplayPrayerController: UITableViewController {

    @IBOutlet var prayerTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var data = ["data"]
    var filtered = ["data"]
    var keys = ["data"]
    var useFiltered = false
    var username = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "All Prayer Requests"
        data.removeAtIndex(0)
        filtered.removeAtIndex(0)
        keys.removeAtIndex(0)
        Reachability.internetCheck()
        
        
        //if user is logged in
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    self.username = Reachability.parseOptional(String(result["name"]))
                    let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/prayers")
                    ref.queryOrderedByChild("date").observeEventType(.ChildAdded, withBlock: { snapshot in
                        if let prayer = snapshot.value["prayer"] as? String {
                            var date = Reachability.parseOptional(String(snapshot.value["date"]))
                            
                            if(!date.containsString(".")) {
                                date = Reachability.epochtoDate(Double(date)!)
                            }

                            let name = Reachability.parseOptional(String(snapshot.value["author"]))
                            print("\(snapshot.key) prayer:  \(prayer)")
                            self.self.data.append("\(prayer) \r\nby \(name) on \(date)")
                            self.self.keys.append(snapshot.key)
                            
                            //add to filtered if prayer is own prayer
                            if(name == Reachability.parseOptional(String(result["name"]))) {
                                self.self.filtered.append("\(prayer) \r\nby \(name) on \(date)")
                            }
                            self.prayerTableView.reloadData()
                        }
                    })
                    print(self.data)
                }
            })
        }
    }
    
 
    @IBAction func toggle(sender: AnyObject) {
        useFiltered = !useFiltered
        
        if(useFiltered) {
            self.title = "Personal Prayer Requests"
        }else{
            self.title = "All Prayer Requests"
        }
        prayerTableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(useFiltered){
            return filtered.count
        }
        return data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath)
        
        if(useFiltered) {
            cell.textLabel?.text = filtered[filtered.count - indexPath.row - 1]
        }else {
            cell.textLabel?.text = data[data.count - indexPath.row - 1]
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if useFiltered && editingStyle == .Delete {
            
            //remove prayer from data
            let message = filtered[filtered.count - indexPath.row - 1]
            var index = 0
            for str in data {
                if(message == str){
                    data.removeAtIndex(index)
                    break
                }
                index+=1
            }
            print(index)
            print(data)
            print(keys)
            
            //remove from database
            let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/prayers")
            let ref2 = ref.childByAppendingPath(keys[index])
            print(ref2)
            ref2.removeValue()
            
            //remove key from array
            keys.removeAtIndex(index)
            
            //remove prayer from filtered
            filtered.removeAtIndex(filtered.count - indexPath.row - 1)
            
            //remove from row
            prayerTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        
        //removing prayer from all prayer table as admin
        if !useFiltered && username == "Bryan Sugiarto" && editingStyle == .Delete {
            let message = data[data.count - indexPath.row - 1]
            var index = 0
            for str in data {
                if(message == str){
                    data.removeAtIndex(index)
                    var index2 = 0
                    for str2 in filtered {
                        if(message == str2){
                            filtered.removeAtIndex(index2)
                            break
                        }
                        index2+=1
                    }
                    
                    break
                }
                index+=1
            }
            print(index)
            print(data)
            print(keys)
            
            //remove from database
            let ref = Firebase(url: "https://crackling-inferno-4721.firebaseio.com/prayers")
            let ref2 = ref.childByAppendingPath(keys[index])
            print(ref2)
            ref2.removeValue()
            
            //remove key from array
            keys.removeAtIndex(index)
            
            //remove from row
            prayerTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        //remove prayer that is not authorized
        else if !useFiltered && editingStyle == .Delete {
                let alertView = UIAlertView();
                alertView.addButtonWithTitle("Ok");
                alertView.title = "Invalid Access";
                alertView.message = "Please Toggle to Delete Prayer";
                alertView.show();
        }
    }
    
}

