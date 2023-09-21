//
//  UIView+Extension.swift
//  FlashChat
//
//  Created by mac on 12/09/2023.
//

import UIKit

extension UIView{
    func addRadius(radius: CGFloat){
        layer.cornerRadius = radius*iPhoneXFactor
        
    }
    func addBorder(color: Colors, width: CGFloat){
        layer.borderColor = UIColor(named: color.rawValue)?.cgColor
        layer.borderWidth = width
    }
    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }
    public var left: CGFloat {
        return frame.origin.x
    }
    public var highht: CGFloat{
        return frame.size.height
    }
    public var widtth: CGFloat{
        return frame.size.width
    }
    public var top: CGFloat{
        return frame.origin.y
    }
    public var bottom: CGFloat{
        return frame.size.height + frame.origin.y
    }
}

extension Notification.Name{
    static let didLongInNotification = Notification.Name("didLogInNotification")
}
