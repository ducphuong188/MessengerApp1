//
//  MenuVC.swift
//  MessengerApp
//
//  Created by macbook on 14/11/2023.
//

import UIKit
import FirebaseFirestore
class MenuVC: UIViewController {
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(FollowCell.self, forCellReuseIdentifier: FollowCell.identifier)
        return table
    }()
    var id = ""
    var email = ""
    var fllower = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetechData()
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    func fetechData() {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { QuerySnapshot, error in
            guard QuerySnapshot == QuerySnapshot, error == nil else {return}
            let data = QuerySnapshot?.documents[0].data()
            let followers = data?["followers"] as! [String]
            self.fllower = followers
            DispatchQueue.main.async { [self] in
                tableView.reloadData()
            }
        }
    }

    

}
extension MenuVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fllower.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FollowCell.identifier) as! FollowCell
        let model = fllower[indexPath.row]
        cell.configure(model: model)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
}
