//
//  ViewController.swift
//  FlashChat
//
//  Created by mac on 12/09/2023.
//

import UIKit
import CLTypingLabel
import FirebaseAuth
import JGProgressHUD

class LoginVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var appTitle: CLTypingLabel!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var loginnBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    private let spinner = JGProgressHUD(style: .dark)
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        if isValidLogin() {
            if let email = emailTxtField.text, let password = passwordTxtField.text{
                
                spinner.show(in: view)
                Auth.auth().signIn(withEmail
                                   : email, password: password) { [weak self] authResult, error in
                    guard let strongSelf = self else{
                        return
                    }
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                    guard authResult != nil, error == nil else {
                        displayMessage(message: "Please enter correct Password!", messageError: true)
                        return
                    }
                    let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
                    DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                        switch result {
                        case .success(let data):
                            guard let userData = data as? [String: Any],
                                let firstName = userData["first_name"] as? String,
                                let lastName = userData["last_name"] as? String else {
                                return
                            }
                            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                            
                        case .failure(let error):
                            print("failed to read data\(error)")
                        }
                    })
                    UserDefaults.standard.set(email, forKey: "email")
                    
                    displayMessage(message: "login success", messageError: false)
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "ConversationVC")
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    @IBAction func registerBtnClicked(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "RegisterVC")
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension LoginVC{
    func initUI(){
        hideNavigation()
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.isTranslucent = true
        appTitle.text = "⚡️FlashChat"
        appTitle.charInterval = 1
        emailView.addRadius(radius: 7)
        passwordView.addRadius(radius: 7)
        loginnBtn.addRadius(radius: 7)
        registerBtn.addBorder(color: .C0079FB, width: 1)
        registerBtn.addRadius(radius: 7)
    }
    func isValidLogin()->Bool{
        if emailTxtField.text?.trimmingCharacters(in: .whitespaces) == ""{
            displayMessage(message: "Please Enter Your Email OR Mobile", messageError: true)
            return false
        }
        if !isValidMobileOrEmail(emailTxtField.text?.trimmingCharacters(in: .whitespaces) ?? "" ){
            displayMessage(message: "Please Enter A Valid Email", messageError: true)
            return false
        }
        if passwordTxtField.text?.trimmingCharacters(in: .whitespaces) == ""{
            displayMessage(message: "Please Enter Your Password", messageError: true)
            return false
        }
        if !isValidPassword( passwordTxtField.text?.trimmingCharacters(in: .whitespaces) ?? "" ) {
            displayMessage(message: "Please Enter A Valid Password", messageError: true)
            return false
        }
        return true
    }
}

