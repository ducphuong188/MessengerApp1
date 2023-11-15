//
//  ChatViewTableCell.swift
//  MessengerApp
//
//  Created by macbook on 04/11/2023.
//

import UIKit
import Nuke
protocol ChatViewTableCellDelegate: AnyObject {
    func tapOnOtherProfile(email: String,_ cell: ChatViewTableCell )
}
class ChatViewTableCell: UITableViewCell {
    var delegate: ChatViewTableCellDelegate?
    var model: Conversation?
    static let identifier = "chatCell"
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
     let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()

    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
//    let gesture = UITapGestureRecognizer(target: HomeVC(), action: #selector(tapOnAvatar))
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(timeLabel)
        userImageView.isUserInteractionEnabled = true
//        userImageView.addGestureRecognizer(gesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)

        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height-20)/2)

        userMessageLabel.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLabel.bottom + 10,
                                        width: contentView.width - 20 - userImageView.width,
                                        height: (contentView.height-20)/2)
        timeLabel.frame = CGRect(x: 300, y: 50, width: 80, height: 20)
        
    }
    public func configure(with model: Conversation) {
        self.model = model
        configures(with: model)
    }
    @objc func tapOnAvatar(_ sender: Any) {
        self.delegate?.tapOnOtherProfile(email: model!.otherUserEmail, self)
    }
    
    func getTimeFromDate(_ date: String) -> String {
        
        let dateFormatter: DateFormatter = {
            let formattre = DateFormatter()
            formattre.dateStyle = .medium
            formattre.timeStyle = .long
            formattre.locale = .current
            return formattre
        }()
        
        guard let yourDate = dateFormatter.date(from: date) else { return "12:13" }
        
        
        dateFormatter.dateFormat = "HH:mm"
        let result = dateFormatter.string(from: yourDate)
        
        print(result)
        return result
    }

    public func configures(with model: Conversation) {
        userMessageLabel.text = model.latestMessage.text
        userNameLabel.text = model.name
        timeLabel.text = getTimeFromDate(model.latestMessage.date)
        db.collection("users").whereField("email", isEqualTo: DatabaseManager.shared.restoreEmail(safeEmail: model.otherUserEmail)).limit(to: 1)
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
