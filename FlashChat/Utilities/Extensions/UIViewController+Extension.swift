//
//  UIViewController+Extension.swift
//  FlashChat
//
//  Created by mac on 12/09/2023.
//

import UIKit
extension UIViewController{
    
    func hideNavigation(){
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showNavigation(){
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
