//
//  ProfileVC.swift
//  FlashChat
//
//  Created by mac on 13/09/2023.
//

import UIKit
import FirebaseAuth
import SDWebImage

class ProfileVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var profileTV: UITableView!
    
    //MARK: - Variables
    var data = [ProfileViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/"+fileName
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.self.frame.size.width-150)/2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.self.frame.size.width/2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        
        print("profile picture downloaded successfuly")
        return headerView
    }
}

extension ProfileVC{
    func initUI(){
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")",
                                     handler: nil))
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No email")",
                                     handler: nil))
        
        data.append(ProfileViewModel(viewModelType: .logout,
                                     title: "Log Out",
                                     handler: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let actionSheet = UIAlertController(title: "",
                                                message: "",
                                                preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Log Out",
                                                style: .destructive,
                                                handler: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                //so if the user decided to signOut we will remove it's data from cache so if he wants to register with onother email and open the other account he will not found his first account info
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                do{
                    try FirebaseAuth.Auth.auth().signOut()
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "LoginVC")
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                }
                catch{
                    print("field log out")
                }
                
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            strongSelf.present(actionSheet, animated: true)
            
        }))
        
        
        profileTV.register(ProfileTableViewCell.self,
                           forCellReuseIdentifier: ProfileTableViewCell.identifier)
        profileTV.delegate = self
        profileTV.dataSource = self
        profileTV.tableHeaderView = createTableHeader()
        
        
    }
}

extension ProfileVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
}

extension ProfileVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
}


class ProfileTableViewCell: UITableViewCell{
    
    static let identifier = "ProfileTableViewCell"
    
    public func setUp(with viewModel: ProfileViewModel) {
        textLabel?.text = viewModel.title

        
        switch viewModel.viewModelType{
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        }
    }
}
