//
//  CommonHelper.swift
//  FlashChat
//
//  Created by mac on 12/09/2023.
//

import UIKit
import SwiftMessages


public var screenWidth: CGFloat { get { return UIScreen.main.bounds.size.width } }
public var screenHeight:CGFloat { get { return UIScreen.main.bounds.size.height } }
public var iPhoneXFactor: CGFloat { get {return ((screenWidth * 1.00) / 360.0)} }

func isValidEmail(email: String) -> Bool {
    let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluate(with: email)
}
func isValidMobileNumber(_ mobileNumber: String) -> Bool {
    let mobileNumberRegex = "^\\d{11}$"
    let mobileNumberPredicate = NSPredicate(format: "SELF MATCHES %@", mobileNumberRegex)
    return mobileNumberPredicate.evaluate(with: mobileNumber)
}
func isValidName(_ name: String) -> Bool {
    let nameRegex = "^[a-zA-Z]{4,}$"
    let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
    return namePredicate.evaluate(with: name)
}
func isValidMobileOrEmail(_ input: String) -> Bool {
    let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let mobileNumberRegex = "^\\d{11}$"
    
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    let mobileNumberPredicate = NSPredicate(format: "SELF MATCHES %@", mobileNumberRegex)
    
    return emailPredicate.evaluate(with: input) || mobileNumberPredicate.evaluate(with: input)
}
func isValidPassword(_ password: String) -> Bool {
    //(?=.*[@#$%^&+=])
    
    let passwordRegex = "^(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])(?=.*[@#$%^&+=])(?=\\S+$).{8,}$"
    let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
    return passwordPredicate.evaluate(with: password)
}


public func displayMessage(message: String, messageError: Bool) {
    
    let view = MessageView.viewFromNib(layout: .cardView)
    if messageError == true {
        view.configureTheme(.error)
        view.alpha = 0.5
    } else {
        view.configureTheme(.success)
        view.alpha = 0.8
    }
    view.titleLabel?.isHidden = true
    view.bodyLabel?.text = message
    view.titleLabel?.textColor = UIColor.white
    view.bodyLabel?.textColor = UIColor.white
    view.button?.isHidden = true
    view.alpha = 0.9
    var config = SwiftMessages.Config()
    config.presentationStyle = .bottom
    config.shouldAutorotate = true
    SwiftMessages.show(config: config, view: view)
}
