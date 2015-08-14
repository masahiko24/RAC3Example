//
//  LoginViewController.swift
//  RAC3Example
//
//  Created by Masahiko TSUJITA on 2015/07/26.
//  Copyright (c) 2015年 Masahiko Tsujita. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// View controller which provides an interface to login to the service.
class LoginFormViewController: UIViewController {
    
    // MARK: - Getting View Outlets
    
    /// Text field for username.
    @IBOutlet weak var usernameField: UITextField!
    
    /// Text field for password.
    @IBOutlet weak var passwordField: UITextField!
    
    /// Label for error message.
    @IBOutlet weak var errorLabel: UILabel!
    
    /// Cancel button on the navigation bar.
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    
    /// Login button on the navigation ba.
    @IBOutlet weak var loginButtonItem: UIBarButtonItem!
    
    // MARK: - Managing Event Streams
    
    /// The property of username.
    let username = MutableProperty<String>("")
    
    /// The property of password.
    let password = MutableProperty<String>("")
    
    /// The property of bool value which determines whether user can send login request.
    let canLogin = MutableProperty<Bool>(false)
    
    /// The action which represents canceling login.
    let cancelAction = Action<AnyObject?, AnyObject, NoError> { item in
        return SignalProducer<AnyObject, NoError>.empty
    }
    
    /// The action which represents login to the service.
    private(set) lazy var loginAction: Action<AnyObject?, Account, NSError> = { [unowned self] in
        Action<AnyObject?, Account, NSError>(enabledIf: self.canLogin, { [unowned self] _ in
            return Client.sharedClient().sendLoginRequest(username: self.username.value, password: self.password.value)
        })
    }()
    
    // MARK: - Responding To View Controller Life Cycle Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Bind values of text fields to properties.
        self.username <~ self.usernameField.rac_textSignal().toSignalProducer()
            |> map { $0 as! String }
            |> catch { _ in SignalProducer<String, NoError>.empty }
        
        self.password <~ self.passwordField.rac_textSignal().toSignalProducer()
            |> map { $0 as! String }
            |> catch { _ in SignalProducer<String, NoError>.empty }
        
        // Configures cancel button and event handlings.
        self.cancelButtonItem.rac_command = toRACCommand(cancelAction)
        
        self.cancelAction.events.observe(next: { [unowned self] event in
            switch event {
            case .Completed:
                self.performSegueWithIdentifier(LoginFormViewController.ToTimelineUnwindSegueID, sender: self.cancelButtonItem)
            default:
                break
            }
        })
        
        // Configures login button and event handlings.
        self.loginButtonItem.rac_command = toRACCommand(loginAction)
        
        self.canLogin <~ combineLatest(self.username.producer, self.password.producer)
            |> map { (username, password) in !username.isEmpty && !password.isEmpty }
        
        loginAction.events.observe(next: { [unowned self] event in
            switch event {
            case .Completed:
                self.performSegueWithIdentifier(LoginFormViewController.ToTimelineUnwindSegueID, sender: self.cancelButtonItem)
            case let .Error(boxedError):
                let error = boxedError.value
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                    
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            default:
                break
            }
        })
        
        // Error message
        let error = SignalProducer(values: [
            self.usernameField.rac_textSignal().toSignalProducer()
                |> map { $0 as! String }
                |> map { text in text.isEmpty ? "User name must not be empty!" : "" }
                |> sampleOn(self.usernameField.rac_signalForControlEvents(.EditingDidEnd).toSignalProducer()
                    |> map { $0 as! UITextField }
                    |> map { _ in () }
                    |> catch { _ in SignalProducer<(), NoError>.empty }),
            self.passwordField.rac_textSignal().toSignalProducer()
                |> map { $0 as! String }
                |> map { text in text.isEmpty ? "Password must not be empty!" : "" }
                |> sampleOn(self.passwordField.rac_signalForControlEvents(.EditingDidEnd).toSignalProducer()
                    |> map { $0 as! UITextField }
                    |> map { _ in () }
                    |> catch { _ in SignalProducer<(), NoError>.empty })
            ])
            |> flatten(.Merge)
        
        DynamicProperty(object: self.errorLabel, keyPath: "text") <~ error
            |> map { $0 as AnyObject? }
            |> catch { _ in return SignalProducer<AnyObject?, NoError>.empty }
        
        
    }
    
    // MARK: - Responding
    
    /// The string identifies unwind segue to the presenting timeline view controller.
    static let ToTimelineUnwindSegueID = "ToTimelineUnwindSegue"
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier {
            switch id {
            case self.dynamicType.ToTimelineUnwindSegueID:
                //  Prepare for unwind segue to timeline view controller...
                break
            default:
                break
            }
        }
    }

}
