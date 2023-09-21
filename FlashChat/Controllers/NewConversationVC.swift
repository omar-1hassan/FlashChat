//
//  NewConversationVC.swift
//  FlashChat
//
//  Created by mac on 14/09/2023.
//
import UIKit
import JGProgressHUD

class NewConversationVC: UIViewController {
    
    public var completion: ((SearchResult) -> (Void))?
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    private var hasFetched = false
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users....."
        return searchBar
    }()
    //this table to show the result of the search
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationCell.self, forCellReuseIdentifier: NewConversationCell.identifier)
        return table
    }()
    //label to show there's no users found for what the user is searching
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.text = "No Results"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        view.addSubview(noResultLabel)
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        //this will invoked keyboaed on the search bar as soon as view did load is loads
        searchBar.becomeFirstResponder()
        
    }
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.frame.size.width/4, y: (view.frame.size.height-200)/2, width: view.frame.size.width/2, height: 200)
    }
    
}
extension NewConversationVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //start conversation
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
            
        })
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}
extension NewConversationVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier , for: indexPath) as! NewConversationCell
        cell.configure(with: model)
        return cell
    }
    
    
}

extension NewConversationVC: UISearchBarDelegate{
    //Gets called when the user taps on the search button on the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //we want to grap the text from the search bar th search for this user name
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        //        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        searchUsers(query: text)
    }
    //The function of searching for users in our data base
    func searchUsers(query: String) {
        //check if array has firebase results
        if hasFetched {
            //if it does: filter
            filterUsers(with: query)
            
        } else{
            //if not fetch then filter
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
    }
    func filterUsers(with term: String) {
        //update the UI: either show result or show no result label
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: currentUserEmail)
        
        self.spinner.dismiss()
        //if the user is serarching for latter a and his account name starts with a never show his account on the search results and return false
        let results: [SearchResult] = users.filter({
            guard let email = $0["email"] ,
                  email != safeEmail else {
                return false
            }
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
            
        }) .compactMap({
            guard let email = $0["email"],
                  let name = $0["name"] else {
                return nil
            }
            return SearchResult(name: name, email: email)
        })
        self.results = results
        updateUI()
    }
    // This function based on if there are results will show them in the table otherwise show the no result label
    func updateUI() {
        if results.isEmpty {
            noResultLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noResultLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}
