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
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
    public var left: CGFloat {
        return self.frame.origin.x
    }
    public var highht: CGFloat{
        return self.frame.size.height
    }
    public var widtth: CGFloat{
        return self.frame.size.width
    }
    public var top: CGFloat{
        return self.frame.origin.y
    }
    public var bottom: CGFloat{
        return self.frame.size.height + self.frame.origin.y
    }
}
