//
//  ChatVC.swift
//  FlashChat
//
//  Created by mac on 12/09/2023.
//

import UIKit
import FirebaseAuth

class ConversationVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    //this will handel if there is no current user or not if not it will show loginVC
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil{
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "LoginVC")
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }

}
