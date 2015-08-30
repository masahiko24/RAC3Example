//
//  UIKit+ReactiveCocoa3.swift
//  RAC3Example
//
//  Created by 辻田晶彦 on 2015/08/30.
//  Copyright (c) 2015年 Masahiko Tsujita. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension UIControl {
    
    func signalForControlEvents(events: UIControlEvents) -> SignalProducer<AnyObject?, NoError> {
        return self.rac_signalForControlEvents(events).toSignalProducer()
            |> catch { _ in SignalProducer<AnyObject?, NoError>.empty }
    }
    
}

extension UITextField {
    
    var textSignalProducer: SignalProducer<String, NoError> {
        get {
            return self.rac_textSignal().toSignalProducer()
                |> map { $0 as! String }
                |> catch { _ in SignalProducer.empty }
        }
    }
    
}

extension UIBarButtonItem {
    
    var reactiveCocoaAction: Action<AnyObject?, AnyObject?, NSError>? {
        get {
            return self.rac_command.toAction()
        }
        set {
            if let action = newValue {
                self.rac_command = toRACCommand(action)
            } else {
                self.rac_command = nil
            }
        }
    }
    
}
