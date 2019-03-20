//
//  MessagesViewController.swift
//  TranslYAtor
//
//  Created by Leon Vladimirov on 2/2/19.
//  Copyright © 2019 Leon Vladimirov. All rights reserved.
//

import UIKit

// Handles all of the messages
class MessagesViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Rotate UITableView to create messenger interface and add observers
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)

        NotificationCenter.default.addObserver(self, selector: #selector(SendMessage), name: NSNotification.Name(rawValue: "Request"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SendMessage), name: NSNotification.Name(rawValue: "Answer"), object: nil)
        
    }
    var messages = [String]()
    var cellReuseIdentifier = "Request"
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if request == "0" && indexPath.row % 2 == 0{
            cellReuseIdentifier = "Answer"
           
        } else {
            cellReuseIdentifier = "Request"
        }
        
        let cell:MessageCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MessageCell
        cell.myCellLabel.text = self.messages[indexPath.row]
        // Set Label width
        let myConstraints = [cell.myCellLabel.widthAnchor.constraint(lessThanOrEqualToConstant: cell.frame.width / 2)]

        NSLayoutConstraint.activate(myConstraints)
        
        // rotate cell before returning it
        
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
       
        return cell
    }
    
    var request = ""
    @objc func SendMessage(notification: NSNotification){
        let message = notification.userInfo!["myData"] as! String
        messages.insert(message, at: 0)
        request = notification.userInfo!["request"] as! String
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        self.tableView.endUpdates()
        
    }
    
    
    
}



