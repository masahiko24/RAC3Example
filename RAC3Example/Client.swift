//
//  Client.swift
//  RAC3Example
//
//  Created by Masahiko TSUJITA on 2015/08/13.
//  Copyright (c) 2015年 Masahiko Tsujita. All rights reserved.
//

import Foundation
import ReactiveCocoa

/// Post model.
class Post {
    
    // MARK: - Initializing Posts
    
    /**
    Initializes a post with given properties.
    
    :param: icon     User icon.
    :param: username User name.
    :param: message  Message.
    
    :returns: Post initialized with given properties.
    */
    init(icon: UIImage?, username: String, message: String) {
        self.icon = icon
        self.username = username
        self.message = message
    }
    
    // MARK: - Accessing To The Post Properties
    
    /// User icon.
    var icon: UIImage?
    
    /// User name.
    var username = ""
    
    /// Message.
    var message = ""
    
}

// MARK: - Account

/// The model object represents an account which user logged in.
class Account {
    
    // MARK: - Initializing Accounts
    
    /**
    Initializes an account with user name.
    
    :param: username User name.
    
    :returns: An account object initialized with given user name.
    */
    init(username: String) {
        self.username = username
    }
    
    // MARK: - Accessing To The Account Properties
    
    /// User name.
    var username = ""
    
}

// MARK: - Client

/// Client object.
final class Client {
    
    // MARK: - Getting Shared Instance
    
    private static var instance: Client!
    
    static func sharedClient() -> Client {
        if instance == nil {
            instance = Client()
        }
        return instance
    }
    
    // MARK: - Initializing Client
    
    private init() {
        
    }
    
    // MARK: - Getting Posts
    
    private var posts = [Post]()
    
    /**
    Get a signal producer which represents sending a request getting posts.
    
    :returns: A signal producer which represents sending a request getting posts.
    */
    func sendGETPostsRequest() -> SignalProducer<[Post], NoError> {
        return SignalProducer<[Post], NoError> { sink, disposable in
            let delay = Int64(1.0 * Double(NSEC_PER_SEC))
            let time = dispatch_time(DISPATCH_TIME_NOW, delay)
            dispatch_after(time, dispatch_get_main_queue(), { [unowned self] in
                let messages = [
                    "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                    "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
                    "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                ]
                let count = Int(arc4random_uniform(3))
                for i in 0..<count {
                    let icon = UIImage(named: "user")
                    let message = messages[Int(arc4random_uniform(4))]
                    let post = Post(icon: icon, username: "John Appleseed", message: message)
                    self.posts.insert(post, atIndex: 0)
                    sendNext(sink, self.posts)
                }
                sendCompleted(sink)
            })
        }
    }
    
    // MARK: - Managing User Account And Login Status
    
    /// The property of the account which user is logging in.
    let account = MutableProperty<Account?>(nil)
    
    /**
    Get a signal producer which represents sending a request to login to the service.
    
    :param: username User name.
    :param: password Password for specified user name.
    
    :returns: Signal producer which represents sending arequest to login to the service.
    */
    func sendLoginRequest(#username: String, password: String) -> SignalProducer<Account, NSError> {
        return SignalProducer<Account, NSError> { sink, disposable in
            let delay = Int64(1.0 * Double(NSEC_PER_SEC))
            let time = dispatch_time(DISPATCH_TIME_NOW, delay)
            dispatch_after(time, dispatch_get_main_queue(), { [unowned self] in
                if username == "johnappleseed" && password == "1234" {
                    let account = Account(username: username)
                    self.account.value = account
                    sendNext(sink, account)
                    sendCompleted(sink)
                } else {
                    sendError(sink, NSError(domain: "RAC3ExampleClientErrorDomain", code: 1, userInfo: [
                        NSLocalizedDescriptionKey : "Failed to login. Please confirm that the username and password are correct."]))
                }
            })
        }
    }
    
}