//
//  ProfileVC.swift
//  FlashChat
//
//  Created by mac on 13/09/2023.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var profileTV: UITableView!
    
    //MARK: - Variables
    var data = ["Log Out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
}

extension ProfileVC{
    func initUI(){
        profileTV.delegate = self
        profileTV.dataSource = self
        profileTV.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
    }
}

extension ProfileVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "",
                                            message: "",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                            style: .destructive,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
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
        present(actionSheet, animated: true)
    }
}

extension ProfileVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    
}
