//
//  RegisterVC.swift
//  FlashChat
//
//  Created by mac on 12/09/2023.
//

import UIKit
import CLTypingLabel
import FirebaseAuth
import JGProgressHUD


class RegisterVC: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var appTitle: CLTypingLabel!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var checkBoxBtn: UIButton!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var secondNameTxtField: UITextField!
    @IBOutlet weak var passTxtField: UITextField!
    @IBOutlet weak var rePassTxtField: UITextField!
    @IBOutlet var viiew: [UIView]!
    @IBOutlet weak var userProfileImg: UIImageView!
    
    //MARK: - Variables
    var isChecked: Bool = false
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    @IBAction func checkBoxBtnClicked(_ sender: UIButton) {
        isChecked.toggle()
        changeCheckBoxImg(view: sender, on: .init(named: "check_sel")!, off: .init(named: "check_unsel_sel")!, onOffStatus: isChecked)
    }
    
    @IBAction func registerBtnClicked(_ sender: UIButton) {
        if isValidRegister(){
            
            //Firebase register
            if let email = emailTxtField.text, let password = passTxtField.text, let firstName = firstNameTxtField.text, let lastName = secondNameTxtField.text {
                
                spinner.show(in: view)
                //if registerd user already exists or not
                DatabaseManager.shared.userExists(with: email) { [weak self] exists in
                    guard let strongSelf = self else{
                        return
                    }
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                    guard !exists else{
                        //user already exists
                        displayMessage(message: "User already exists!", messageError: true)
                        return
                    }
                    // create user
                    Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                        guard let strongSelf = self else{
                            return
                        }
                        
                        guard authResult != nil, error == nil else {
                            print("Error creating user")
                            return
                        }
                        
                        let chatUser = ChatAppUser(firstName: firstName,
                                                   email: email,
                                                   lastName: lastName)
                        DatabaseManager.shared.insertUser( with: chatUser, completion: { success in
                            if success {
                                //Upload image
                                guard let image = strongSelf.userProfileImg.image, let data = image.pngData() else {
                                    return
                                }
                                let fileNmae = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileNmae, completion: {result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage manger error\(error)")
                                    }
                                })
                            }
                        })
                        
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "ConversationVC")
                        strongSelf.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                }
            }
        }
    }
}

extension RegisterVC{
    func initUI(){
        appTitle.text = "⚡️FlashChat"
        appTitle.charInterval = 1
        for view in viiew{
            view.addRadius(radius: 7)
        }
        registerBtn.addRadius(radius: 7)
        //To add profile picature photo to the user
        userProfileImg.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        userProfileImg.addGestureRecognizer(gesture)
//                To make the profile photo circular
                userProfileImg.image = UIImage(systemName: "person.circle")
                userProfileImg.tintColor = .gray
                userProfileImg.contentMode = .scaleAspectFit
                userProfileImg.layer.masksToBounds = true
        userProfileImg.layer.cornerRadius = self.userProfileImg.frame.size.width / 2
    }
    @objc private func didTapChangeProfilePic(){
        presentPhotoActionSheet()
        //        print("Change Pic called")
    }
    
    func changeCheckBoxImg(view: UIButton,on: UIImage, off: UIImage, onOffStatus: Bool ){
        switch onOffStatus {
        case true:
            view.setImage(on, for: .normal)
        default:
            view.setImage(off, for: .normal)
        }
    }
    //Validation on our register text fields
    func isValidRegister()->Bool{
        if firstNameTxtField.text?.trimmingCharacters(in: .whitespaces) == "" {
            displayMessage(message: "Please Enter Your Name", messageError: true)
            return false
        }
        if !isValidName(firstNameTxtField.text?.trimmingCharacters(in: .whitespaces) ?? ""){
            displayMessage(message: "Please Enter A Valid Name", messageError: true)
            return false
        }
        if emailTxtField.text?.trimmingCharacters(in: .whitespaces) == "" {
            displayMessage(message: "Please Enter Your Email", messageError: true)
            return false
        }
        if !isValidEmail(email: emailTxtField.text?.trimmingCharacters(in: .whitespaces) ?? ""){
            displayMessage(message: "Please Enter A Valid Email", messageError: true)
            return false
        }
        if secondNameTxtField.text?.trimmingCharacters(in: .whitespaces) == "" {
            displayMessage(message: "Please Enter Your Mobile Number", messageError: true)
            return false
        }
        if !isValidName(secondNameTxtField.text?.trimmingCharacters(in: .whitespaces) ?? ""){
            displayMessage(message: "Please Enter A Valid Name", messageError: true)
            return false
        }
        if passTxtField.text?.trimmingCharacters(in: .whitespaces) == "" {
            displayMessage(message: "Please Enter Your Password", messageError: true)
            return false
        }
        if !isValidPassword(passTxtField.text?.trimmingCharacters(in: .whitespaces) ?? ""){
            displayMessage(message: "Please Enter A Valid Password", messageError: true)
            return false
        }
        if rePassTxtField.text?.trimmingCharacters(in: .whitespaces) == ""  {
            displayMessage(message: "Please Re Enter Your Password", messageError: true)
            return false
        }
        if rePassTxtField.text != passTxtField.text {
            print("Re passord confirmed")
            displayMessage(message: "Please Re Enter Your Password", messageError: true)
            return false
        }
        if !isChecked {
            displayMessage(message: "please agree terms & conditions first", messageError: true)
            return false
        }
        return true
    }
}
//This delegate extension allows us to get result of the user taking a picture or selecting photos of camera
extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //this action sheet gonna have to options for the user 1- take photo --- 2- choose photo
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo" ,
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.prerntCamera()
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentPhotoPicker()
            
        }))
        present(actionSheet, animated: true)
    }
    
    //present the camera to uesr
    func prerntCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc , animated: true)
    }
    //prersnt the photo library to user
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc , animated: true)
    }
    
    //gets called when the user takes a photo or select one
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.userProfileImg.image = selectedImage
    }
    
    //gets called when the user cancel taking a picture or photo selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
