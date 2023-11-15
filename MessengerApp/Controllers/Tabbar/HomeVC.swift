//
//  HomeVC.swift
//  MessengerApp
//
//  Created by macbook on 29/10/2023.
//

import UIKit
import Nuke
class HomeVC: UIViewController {
    
    var nav: UINavigationController?
    
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ChatViewTableCell.self,
                       forCellReuseIdentifier: ChatViewTableCell.identifier)
        return table
    }()

    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    private var conversations = [Conversation]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .done, target: self, action: #selector(deleteAct))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "filemenu.and.cursorarrow"), style: .done, target: self, action: #selector(tapOnMenu))
        navigationItem.title = "Đoạn chat"
        navigationController?.navigationBar.scrollEdgeAppearance = .init(barAppearance: UINavigationBarAppearance())
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        startListeningForCOnversations()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.height-100)/2,
                                            width: view.width-20,
                                            height: 100)
    }
@objc func deleteAct(_ sender: Any) {
    if tableView.isEditing {
        tableView.isEditing = false
    } else {
        tableView.isEditing = true
    }
}
    @objc func tapOnAvatar(_ sender: Any) {
        let str = UIStoryboard(name: "Main", bundle: nil)
        let vc = str.instantiateViewController(withIdentifier: "otherVC") as! OtherProfileVC
        
        present(vc, animated: true)
    }
    
    
    
    
    private func startListeningForCOnversations() {
        let email = Core.shared.getCurrentUserEmail()


            print("starting conversation fetch... \(email)")

            

        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print("successfully got conversation models")
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.noConversationsLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = conversations

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("failed to get convos: \(error)")
            }
        })
    }

}
extension HomeVC: UITableViewDataSource, UITableViewDelegate, ChatViewTableCellDelegate {
    
    
    func tapOnOtherProfile(email: String, _ cell: ChatViewTableCell) {
        DispatchQueue.main.async { [ weak self] in
            guard let strongSelf = self else {
                return
            }
            let str = UIStoryboard(name: "Main", bundle: nil)
            let vc = str.instantiateViewController(withIdentifier: "otherVC") as! OtherProfileVC
            vc.email = email
            strongSelf.present(vc, animated: true)
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let model = conversations[indexPath.row]
            
           DatabaseManager.shared.deleteConversation(conversationId: model.id, completion: {  result in
                if result {
                    print("delelted")
                    self.tableView.reloadData()
                }
                })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatViewTableCell.identifier, for: indexPath) as! ChatViewTableCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                let model = conversations[indexPath.row]
                openConversation(model)
    }
    
    
        
        func openConversation(_ model: Conversation) {
            let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
            vc.title = model.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    
    
    func getTimeFromDate(_ date: String) -> String {
        
        let dateFormatter: DateFormatter = {
            let formattre = DateFormatter()
            formattre.dateStyle = .medium
            formattre.timeStyle = .long
            formattre.locale = .current
            return formattre
        }()
        
        let yourDate = dateFormatter.date(from: date)
        print(yourDate!)
        
        dateFormatter.dateFormat = "HH:mm"
        let result = dateFormatter.string(from: yourDate!)
        
        print(result)
        return result
    }
    
}
