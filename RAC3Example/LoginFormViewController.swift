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
    lazy var username: MutableProperty<String> = {
        let property = MutableProperty<String>("")
        property <~ self.usernameField.rac_textSignal().toSignalProducer()
            |> map { $0 as! String }
            |> catch { _ in SignalProducer.empty }
        return property
    }()
    
    /// The property of password.
    lazy var password: MutableProperty<String> = {
        let property = MutableProperty<String>("")
        property <~ self.passwordField.rac_textSignal().toSignalProducer()
            |> map { $0 as! String }
            |> catch { _ in SignalProducer.empty }
        return property
    }()
    
    /// The property of bool value which determines whether user can send login request.
    lazy var canLogin: MutableProperty<Bool> = {
        let property = MutableProperty<Bool>(false)
        property <~ combineLatest(self.username.producer, self.password.producer)
            |> map { (username, password) in !username.isEmpty && !password.isEmpty }
        return property
    }()
    
    /// The action which represents canceling login.
    let cancelAction = Action<AnyObject?, AnyObject, NoError> { item in
        return SignalProducer.empty
    }
    
    /// The action which represents login to the service.
    private(set) lazy var loginAction: Action<AnyObject?, Account, NSError> = { [unowned self] in
        Action<AnyObject?, Account, NSError>(enabledIf: self.canLogin, { [unowned self] _ in
            return Client.sharedClient().sendLoginRequest(
                username: self.username.value,
                password: self.password.value
            )
        })
    }()
    
    // MARK: - Responding To View Controller Life Cycle Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Binding actions to controls
        self.cancelButtonItem.rac_command = toRACCommand(self.cancelAction)
        self.loginButtonItem.rac_command = toRACCommand(self.loginAction)
        
        //  Moves focus to password text field when `return` key is clicked while username input
        self.usernameField.rac_signalForControlEvents(.EditingDidEndOnExit).toSignalProducer().start(next: { [unowned self] _ in
            self.passwordField.becomeFirstResponder()
        })
        //  Performs login action when `done` key is clicked while password input
        self.passwordField.rac_signalForControlEvents(.EditingDidEndOnExit).toSignalProducer()
            |> catch { _ in SignalProducer<AnyObject?, NoError>.empty }
            |> flatMap(.Merge) { [unowned self] _ in
                return self.loginAction.apply(self.passwordField)
                    |> catch { _ in SignalProducer.empty }
            }
            |> start()
        
        //  Samplers
        let usernameEditingDidEnd = self.usernameField.rac_signalForControlEvents(.EditingDidEnd).toSignalProducer()
            |> map { _ in () }
            |> catch { _ in SignalProducer<(), NoError>.empty }
        let passwordEditingDidEnd = self.passwordField.rac_signalForControlEvents(.EditingDidEnd).toSignalProducer()
            |> map { _ in () }
            |> catch { _ in SignalProducer<(), NoError>.empty }
        
        //  Error message
        let error = SignalProducer(values: [
                self.username.producer
                    |> map { $0.isEmpty ? "Username is empty!" : "" }
                    |> sampleOn(usernameEditingDidEnd),
                combineLatest(self.username.producer, self.password.producer)
                    |> map { (username, password) -> String in
                        if username.isEmpty && password.isEmpty {
                            return "Username and password are empty!"
                        } else if password.isEmpty {
                            return "Password is empty!"
                        } else {
                            return ""
                        }
                    }
                    |> sampleOn(passwordEditingDidEnd)
            ])
            |> flatten(.Merge)
        
        //  Binding signal of error message with text of label
        DynamicProperty(object: self.errorLabel, keyPath: "text") <~ error
            |> map { $0 as AnyObject? }
            |> catch { _ in SignalProducer.empty }
        
        //  Responding to cancel action
        self.cancelAction.events.observe(next: { [unowned self] event in
            switch event {
            case .Completed:
                self.performSegueWithIdentifier(LoginFormViewController.ToTimelineUnwindSegueID, sender: self.cancelButtonItem)
            default:
                break
            }
        })
        
        //  Responding to login action
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
