//
//  UITextViewExtension.swift
//  BugTracker
//
//  Created by Marcus Choi on 5/16/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

extension UITextView
{
    func addDismissButton(target: Any, selector: Selector)
    {
        let toolBar = UIToolbar(frame: CGRect(x:0,y:0,width:UIScreen.main.bounds.width, height:44))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: selector)
        
        toolBar.setItems([flexButton, doneButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}

extension UITextField
{
    func addDismissButton(target: Any, selector: Selector)
    {
        let toolBar = UIToolbar(frame: CGRect(x:0,y:0,width:UIScreen.main.bounds.width, height:44))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: selector)
        
        toolBar.setItems([flexButton, doneButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}
