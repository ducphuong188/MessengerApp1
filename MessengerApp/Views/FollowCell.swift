//
//  FollowCell.swift
//  MessengerApp
//
//  Created by macbook on 15/11/2023.
//

import UIKit
import FirebaseFirestore
import Nuke
class FollowCell: UITableViewCell {
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
static let identifier = "cell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
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
    }
    public func configure(model: String) {
        db.collection("users").document(model).getDocument { [self] DocumentSnapshot, error in
            guard DocumentSnapshot == DocumentSnapshot, error == nil else {
                return
            }
            let data = DocumentSnapshot?.data()
            userNameLabel.text = data?["fullname"] as? String
            let urlStr = URL(string: (data?["avatar"] as! String))
            let urlReq = URLRequest(url: urlStr!)
            Nuke.loadImage(with: urlReq, into: userImageView)
        }
    }
}
