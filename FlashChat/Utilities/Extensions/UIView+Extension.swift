//
//  UIView+Extension.swift
//  FlashChat
//
//  Created by mac on 12/09/2023.
//

import UIKit

extension UIView{
    func addRadius(radius: CGFloat){
        self.layer.cornerRadius = radius*iPhoneXFactor
        
    }
    func addBorder(color: Colors, width: CGFloat){
        self.layer.borderColor = UIColor(named: color.rawValue)?.cgColor
        self.layer.borderWidth = width
    }
}
