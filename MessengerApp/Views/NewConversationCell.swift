//
//  NewConversationCell.swift
//  MessengerApp
//
//  Created by macbook on 04/11/2023.
//

import Foundation
import SDWebImage
import Nuke
protocol NewConversationCellDelegate: AnyObject {
    func tapOnIbDelegate(email: String, name: String)
    func tapOnPrDelegate(email: String, name: String)
}
class NewConversationCell: UITableViewCell {
    var delegate: NewConversationCellDelegate?
var email1 = ""
    var name1 = ""
    static let identifier = "NewConversationCell"
    private let leftBt: UIButton = {
        let button = UIButton()
        button.setTitle("IB", for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 15.0)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        return button
    }()
    private let rightBt: UIButton = {
        let button = UIButton()
        button.setTitle("PR", for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 15.0)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        return button
    }()
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(leftBt)
        contentView.addSubview(rightBt)
        leftBt.addTarget(self, action: #selector(tapOnIb), for: .touchUpInside)
        rightBt.addTarget(self, action: #selector(tapOnPr), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 70,
                                     height: 70)

        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 20,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: 50)
        rightBt.frame = CGRect(x: contentView.width-80, y: 0, width: 80, height: contentView.height)
        leftBt.frame = CGRect(x: contentView.width - 160, y: 0, width: 80, height: contentView.height)
    }
    @objc func tapOnIb() {
        self.delegate?.tapOnIbDelegate(email: email1, name: name1)
    }
    @objc func tapOnPr() {
        self.delegate?.tapOnPrDelegate(email: email1, name: name1)
    }
    public func configure(with model: SearchResult) {
        userNameLabel.text = model.name
        name1 = model.name
        self.email1 = DatabaseManager.shared.restoreEmail(safeEmail: model.email)
        db.collection("users").whereField("email", isEqualTo: DatabaseManager.shared.restoreEmail(safeEmail: model.email)).limit(to: 1)
            .getDocuments{ (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    if querySnapshot!.documents.count == 1 {
                        let data = querySnapshot?.documents[0].data()
                        
                        let urlStr = URL(string: (data?["avatar"] as! String))
                        let urlReq = URLRequest(url: urlStr!)
                        Nuke.loadImage(with: urlReq, into: self.userImageView)
                    }
                }
            }
    }

}

