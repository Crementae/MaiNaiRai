//
//  extensionViewController.swift
//  MaiNaiRai
//
//  Created by Adisorn Chatnaratanakun on 12/9/2559 BE.
//  Copyright © 2559 Adisorn Chatnaratanakun. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer? = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap!)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
