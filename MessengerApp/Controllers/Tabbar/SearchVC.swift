//
//  SearchVC.swift
//  MessengerApp
//
//  Created by macbook on 29/10/2023.
//

import UIKit
import JGProgressHUD

final class SearchVC: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)

    private var users = [[String: String]]()

    private var results = [SearchResult]()
    private var results1 = [SearchResult]()
    private var hasFetched = false

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationCell.self,
                       forCellReuseIdentifier: NewConversationCell.identifier)
        return table
    }()
    private let tableView1: UITableView = {
        let table = UITableView()
        
        table.register(NewConversationCell.self,
                       forCellReuseIdentifier: NewConversationCell.identifier)
        return table
    }()
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    private let label1: UILabel = {
        let label = UILabel()
        label.text = "Gợi ý"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        view.addSubview(tableView1)
        view.addSubview(label1)
        tableView1.delegate = self
        tableView1.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        fetechdata()
        searchBar.delegate = self
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label1.frame = CGRect(x: 15, y: 110, width: 50, height: 30)
        tableView1.frame = CGRect(x: 0, y: label1.bottom, width: view.width, height: view.height - 150)
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }

    @objc private func dismissSelf() {
        searchBar.text = nil
        tableView.isHidden = true
        tableView1.isHidden = false
        label1.isHidden = false
        searchBar.endEditing(true)
    }
    func fetechdata() {
        let currentUserEmail = Core.shared.getCurrentUserEmail()
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
            switch result {
            case .success(let usersCollection):
                self?.users = usersCollection
                for i in 0..<usersCollection.count {
                    let email = usersCollection[i]["email"]
                    if email == safeEmail {
                        self?.users.remove(at: i)
                    }
                }
                
                DispatchQueue.main.async {
                    self?.tableView1.reloadData()
                }
            case .failure(let error):
                print("Failed to get usres: \(error)")
            }
        })
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView1 {
            return users.count
        } else {
            return results.count
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableView1 {
            let email = users[indexPath.row]["email"]
            let name = users[indexPath.row]["name"]
            let model = SearchResult(name: name!, email: email!)
            let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier,
                                                     for: indexPath) as! NewConversationCell
            cell.configure(with: model)
            cell.delegate = self
            return cell
        } else {
            let model = results[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier,
                                                     for: indexPath) as! NewConversationCell
            cell.configure(with: model)
            cell.delegate = self
            return cell
        }
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        // start conversation
//        let targetUserData = results[indexPath.row]
////        dismiss(animated: true, completion: { [weak self] in
////            self?.completion?(targetUserData)
////        })
//        let name = targetUserData.name
//        let email = DatabaseManager.safeEmail(emailAddress: targetUserData.email)
//        DatabaseManager.shared.conversationExists(iwth: email, completion: { [weak self] result in
//            guard let strongSelf = self else {
//                return
//            }
//            switch result {
//            case .success(let conversationId):
//                let vc = ChatViewController(with: email, id: conversationId)
//                vc.isNewConversation = false
//                vc.title = name
//                vc.navigationItem.largeTitleDisplayMode = .never
//                strongSelf.navigationController?.pushViewController(vc, animated: true)
//            case .failure(_):
//                let vc = ChatViewController(with: email, id: nil)
//                vc.isNewConversation = true
//                vc.title = name
//                vc.navigationItem.largeTitleDisplayMode = .never
//                strongSelf.navigationController?.pushViewController(vc, animated: true)
//            }
//        })
//    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension SearchVC: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }

        searchBar.resignFirstResponder()

        results.removeAll()
        spinner.show(in: view)

        searchUsers(query: text)
    }

    func searchUsers(query: String) {
        // check if array has firebase results
        if hasFetched {
            // if it does: filter
            filterUsers(with: query)
        }
        else {
            // if not, fetch then filter
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get usres: \(error)")
                }
            })
        }
    }

    func filterUsers(with term: String) {
        let currentUserEmail = Core.shared.getCurrentUserEmail()
        // update the UI: eitehr show results or show no results label
        guard  hasFetched else {
            return
        }

        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)

        self.spinner.dismiss()

        let results: [SearchResult] = users.filter({
            guard let email = $0["email"], email != safeEmail else {
                return false
            }

            guard let name = $0["name"]?.lowercased() else {
                return false
            }

            return name.hasPrefix(term.lowercased())
        }).compactMap({

            guard let email = $0["email"],
                let name = $0["name"] else {
                return nil
            }

            return SearchResult(name: name, email: email)
        })

        self.results = results

        updateUI()
    }

    func updateUI() {
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
            tableView1.isHidden = false
            label1.isHidden = false
        }
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
            tableView1.isHidden = true
            label1.isHidden = true
        }
    }

}
extension SearchVC: NewConversationCellDelegate {
    func tapOnIbDelegate(email: String, name: String) {
        let email = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.conversationExists(iwth: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })

    }
    
    func tapOnPrDelegate(email: String, name: String) {
        let str = UIStoryboard(name: "Main", bundle: nil)
        let vc = str.instantiateViewController(withIdentifier: "otherVC") as! OtherProfileVC
        vc.email = email
        present(vc, animated: true)
    }
    
    
}
