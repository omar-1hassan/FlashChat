//
//  ChatVC.swift
//  FlashChat
//
//  Created by mac on 12/09/2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationVC: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    private let noConversationsLabel: UILabel = {
       let label = UILabel()
        label.text = "No Convesrations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        showNavigation()
//        self.tabBarController?.tabBar.isHidden = false
//        self.tabBarController?.tabBar.isTranslucent = false
//        navigationItem.leftBarButtonItem?.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        fetchConversations()
        initUI()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    //To check if there is a user loged in or not
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

extension ConversationVC{
    func initUI(){
        showNavigation()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    func fetchConversations(){
        tableView.isHidden = false
    }
    @objc private func didTapComposeButton(){
        let vc = NewConversationVC()
        vc.completion = { [weak self] result in
            print("\(result)")
            self?.createNewConversation(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    private func createNewConversation(result: [String: String]) {
        let vc = ChatsVC()
        vc.title = "Omar mohamed"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ConversationVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatsVC()
        vc.title = "Omar mohamed"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)

    }
    
}

extension ConversationVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:  indexPath)
        cell.textLabel?.text = "Hello"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
}
