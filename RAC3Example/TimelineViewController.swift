//
// Created by Masahiko TSUJITA on 2015/08/08.
// Copyright (c) 2015 Masahiko Tsujita. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// Post cell.
class PostCell : UITableViewCell {
    
    /// Image view for user icon.
    @IBOutlet weak var iconView: UIImageView!
    
    /// Text label for user name.
    @IBOutlet weak var usernameLabel: UILabel!
    
    /// Text label for message.
    @IBOutlet weak var messageLabel: UILabel!
    
}

/// A View controller which provides an interface to manage timeline like Twitter.
class TimelineViewController : UITableViewController {
    
    // MARK: - View Outlets
    
    /// Login button item
    @IBOutlet weak var loginButtonItem: UIBarButtonItem!
    
    // MARK: - Responding To View Controller Life Cycle Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Action to be invoked when refresh control is toggled.
        self.refreshControl!.rac_command = toRACCommand(Action<AnyObject?, NSObject, NoError> ({ [unowned self] (control) in
            return SignalProducer<NSObject, NoError>({ [unowned self] (sink, disposable) in
                let aSink = sink
                disposable.addDisposable(Client.sharedClient().sendGETPostsRequest().start(completed: {
                    sendCompleted(aSink)
                }, next: { [unowned self] posts in
                    self.posts.put(posts)
                }))
            })
        }))
        
        //  Action to be invoked when "Login" button in nav bar.
        self.loginButtonItem.rac_command = toRACCommand(Action<AnyObject?, NSObject, NoError> ({ [unowned self] (item) in
            self.performSegueWithIdentifier(TimelineViewController.ToLoginFormSegueID, sender: item)
            return SignalProducer<NSObject, NoError>.empty
        }))
        
        //  Reloads the table view when posts are updated.
        posts.producer.start(next: { [unowned self] (_) in
            self.tableView.reloadData()
        })
        
    }
    
    // MARK: - Managing Table View Contents
    
    var posts = MutableProperty<[Post]>([])
    
    // MARK: - Managing Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.value.count
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        let post = self.posts.value[indexPath.row]
        cell.iconView.image = post.icon
        cell.usernameLabel.text = post.username
        cell.messageLabel.text = post.message
        return cell
    }
    
    // MARK: Responding To Events On View Transitions
    
    static let ToLoginFormSegueID = "TimelineToLoginForm"
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier {
            switch id {
            case TimelineViewController.ToLoginFormSegueID:
                //  Prepare for segue to login form...
                break
            default:
                fatalError("Unknown Segue ID: \(id)")
                break
            }
        }
    }
    
    @IBAction func prepareForUnwindSegueFromLoginForm(segue: UIStoryboardSegue) {
        //  Prepare for segue from login form...
    }

}
