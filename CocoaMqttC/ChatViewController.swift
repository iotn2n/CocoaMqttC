//
//  EventBus.swift
//  CocoaMqttC
//
//  Created by iotn2n on 16/4/23.
//  Copyright © 2016年 iot. All rights reserved.
//

import UIKit
import SwiftEventBus
import CocoaMQTT

class ChatViewController: UIViewController {
    var animal: String? {
        didSet {
            animalAvatarImageView.image = UIImage(named: animal!)
            if let animal = animal {
                switch animal {
                case "Sheep":
                    sloganLabel.text = "Four legs good, two legs bad."
                case "Pig":
                    sloganLabel.text = "All animals are equal."
                case "Horse":
                    sloganLabel.text = "I will work harder."
                default:
                    break
                }
            }
        }
    }
    
    var messages: [ChatMessage] = [] {
        didSet {
            tableView.reloadData()
            scrollToBottom()
        }
    }
    
   
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            messageTextView.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var animalAvatarImageView: UIImageView!
    @IBOutlet weak var sloganLabel: UILabel!
    
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendMessageButton: UIButton! {
        didSet {
            sendMessageButton.enabled = false
        }
    }
    
    @IBAction func sendMessage() {
        let message = messageTextView.text
        if let client = animal {
            let msg = CocoaMQTTMessage.init(topic: "chat/room/animals/client/" + client, string: message, qos: .QOS1)
            SwiftEventBus.post("publish", sender: msg)
        }
        
        messageTextView.text = ""
        sendMessageButton.enabled = false
        messageTextViewHeightConstraint.constant = messageTextView.contentSize.height
        messageTextView.layoutIfNeeded()
        view.endEditing(true)
    }
    @IBAction func disconnect() {
        navigationController?.popViewControllerAnimated(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        SwiftEventBus.unregister(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.hidden = true
        animal = tabBarController?.selectedViewController?.tabBarItem.title
        automaticallyAdjustsScrollViewInsets = false
        messageTextView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        SwiftEventBus.onMainThread(self, name:"receivedMessage") { notification in
            let msg : CocoaMQTTMessage = notification.object as! CocoaMQTTMessage
            self.receivedMessage(msg)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChanged:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        SwiftEventBus.unregister(self)
    }
    
    
    func keyboardChanged(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let keyboardValue = userInfo["UIKeyboardFrameEndUserInfoKey"]
       
        let bottomDistance = UIScreen.mainScreen().bounds.size.height - (self.navigationController?.navigationBar.frame.height)! - keyboardValue!.CGRectValue.origin.y
    
        if bottomDistance > 0 {
            inputViewBottomConstraint.constant = bottomDistance
        } else {
            inputViewBottomConstraint.constant = 0
        }
        view.layoutIfNeeded()
    }
   
    func receivedMessage(msg: CocoaMQTTMessage) {
        let content = msg.string
        let topic = msg.topic
        let sender = topic.stringByReplacingOccurrencesOfString("chat/room/animals/client/", withString: "")
        let chatMessage = ChatMessage(sender: sender, content: content!)
        self.messages.append(chatMessage)
    }

    func scrollToBottom() {
        let count = messages.count
        if count > 3 {
            let indexPath = NSIndexPath(forRow: count - 1, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        }
    }
}


extension ChatViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        if textView.contentSize.height != textView.frame.size.height {
            let textViewHeight = textView.contentSize.height
            if textViewHeight < 100 {
                messageTextViewHeightConstraint.constant = textViewHeight
                textView.layoutIfNeeded()
            }
        }
        
        if textView.text == "" {
            sendMessageButton.enabled = false
        } else {
            sendMessageButton.enabled = true
        }
    }
    
}



extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if message.sender == animal {
            let cell = tableView.dequeueReusableCellWithIdentifier("rightMessageCell", forIndexPath: indexPath) as! ChatRightMessageCell
            cell.contentLabel.text = messages[indexPath.row].content
            cell.avatarImageView.image = UIImage(named: animal!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("leftMessageCell", forIndexPath: indexPath) as! ChatLeftMessageCell
            cell.contentLabel.text = messages[indexPath.row].content
            cell.avatarImageView.image = UIImage(named: message.sender)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        view.endEditing(true)
    }
}
