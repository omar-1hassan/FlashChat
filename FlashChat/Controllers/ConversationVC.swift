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
    
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
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
        startListeningForConversation()
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
    
    private func startListeningForConversation(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else{
                    return
                }
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to get conversations\(error)")
            }
        })
    }
    
    @objc private func didTapComposeButton(){
        let vc = NewConversationVC()
        vc.completion = { [weak self] result in
            self?.createNewConversation(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    private func createNewConversation(result: [String: String]) {
        
        guard let name = result["name"],
              let email = result["email"] else {
            return
        }
        let vc = ChatsVC(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ConversationVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
        let vc = ChatsVC(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}

extension ConversationVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for:  indexPath) as! ConversationTableViewCell
        cell.configure(with: model)

        return cell
    }
    
}
struct Conversation{
    let id: String
    let name: String
    let otherUserEmail: String
    let latesMessage: LatestMessage
}
struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
