//
//  OtherProfileVC.swift
//  MessengerApp
//
//  Created by macbook on 29/10/2023.
//

import UIKit
import FirebaseFirestore
import Nuke
class OtherProfileVC: UIViewController {
    
    @IBOutlet weak var avatarBia: UIImageView!
    
    @IBOutlet weak var avatarChinh: UIImageView!
    
    @IBOutlet weak var fullnameLb: UILabel!
    
    @IBOutlet weak var fllowerLb: UILabel!
    
    @IBOutlet weak var fllowingLb: UILabel!
    
    @IBOutlet weak var emailLb: UILabel!
    
    @IBOutlet weak var phoneLb: UILabel!
    
    @IBOutlet weak var dobLb: UILabel!
    
    @IBOutlet weak var genderLb: UILabel!
    
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var followBt: UIButton!
    @IBOutlet weak var addressLb: UILabel!
    var email = ""
    override func viewDidLoad() {
        super.viewDidLoad()
fetech()
        avatarBia.contentMode = .scaleAspectFill
        img1.contentMode = .scaleAspectFill
        img2.contentMode = .scaleAspectFill
        img3.contentMode = .scaleAspectFill
        avatarChinh.contentMode = .scaleAspectFill
        avatarChinh.layer.borderWidth = 2
        avatarChinh.layer.masksToBounds = true
        avatarChinh.layer.cornerRadius = avatarChinh.frame.width/2
        print(email)
    }
    @IBAction func tapFollow(_ sender: Any) {
        db.collection("users").whereField("email", isEqualTo: self.email).getDocuments { [self] querySnapshot, error1 in
            guard querySnapshot == querySnapshot, error1 == nil else {
                return
            }
            let data = querySnapshot?.documents[0].data()
            let user_id = data?["UID"] as! String
            
                db.collection("users").document(Core.shared.getCurrentUserID()).getDocument { [self] (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        var following = data?["following"] as! [String]
                        
                        let index = following.firstIndex(of: user_id)
                        
                        if index != nil {
                            following.remove(at: index!)
                            
                            followBt.setTitle("FOLLOWING", for: .normal)
                            
                            db.collection("users").document(user_id).getDocument { [self] (document, error) in
                                if let document = document, document.exists {
                                    let data = document.data()
                                    var followers = data?["followers"] as! [String]
                                    
                                    let index = followers.firstIndex(of: Core.shared.getCurrentUserID())
                                    
                                    if index != nil {
                                        followers.remove(at: index!)
                                    }
                                    
                                    fllowerLb.text = "\(followers.count) followers"
                                    db.collection("users").document(user_id).updateData(["followers" : followers])

                                } else {
                                    print("Document does not exist")
                                }
                            }
                        } else {
                            following.append(user_id)
                            
                            followBt.setTitle("UNFOLLOW", for: .normal)
                            
                            db.collection("users").document(user_id).getDocument { [self] (document, error) in
                                if let document = document, document.exists {
                                    let data = document.data()
                                    var followers = data?["followers"] as! [String]
                                    
                                    followers.append(Core.shared.getCurrentUserID())
           
                                    fllowerLb.text = "\(followers.count) followers"
                                    db.collection("users").document(user_id).updateData(["followers" : followers])

                                } else {
                                    print("Document does not exist")
                                }
                            }
                        }
                        
                        db.collection("users").document(Core.shared.getCurrentUserID()).updateData(["following" : following])

                        } else {
                            print("Document does not exist")
                        }
                }
            }
        
    }
    
//    func fetchData() {
//        db.collection("users").whereField("email", isEqualTo: self.email).getDocument { [self] documentSnapshot, error in
//            guard documentSnapshot == documentSnapshot, error == nil, ((documentSnapshot?.exists) != nil) else {
//                return
//            }
//            let data = documentSnapshot?.data()
//            let urlStr = URL(string: (data?["avatar"] as! String))
//            let urlReq = URLRequest(url: urlStr!)
//            let options = ImageLoadingOptions(
//              placeholder: UIImage(systemName: "person.circle"),
//              transition: .fadeIn(duration: 0.5)
//            )
//            Nuke.loadImage(with: urlReq, options: options, into: avatarChinh)
//            fullnameLb.text = data?["fullname"] as? String
//            emailLb.text = data?["email"] as? String
//            dobLb.text = data?["dateOfBirth"] as? String
//            genderLb.text = data?["gender"] as? String
//            addressLb.text = data?["address"] as? String
//            phoneLb.text = data?["phone"] as? String
//            let following = data?["following"] as! [String]
//            fllowingLb.text = "\(following.count) following"
//
//            let followers = data?["followers"] as! [String]
//            fllowerLb.text = "\(followers.count) followers"
//        }
//    }
    func fetech() {
        db.collection("users").whereField("email", isEqualTo: self.email).getDocuments { [self] querySnapshot, error1 in
            guard querySnapshot == querySnapshot, error1 == nil else {
                return
            }
            let data = querySnapshot?.documents[0].data()
            let urlStr = URL(string: (data?["avatar"] as! String))
            let urlReq = URLRequest(url: urlStr!)
            let options = ImageLoadingOptions(
              placeholder: UIImage(systemName: "person.circle"),
              transition: .fadeIn(duration: 0.5)
            )
            Nuke.loadImage(with: urlReq, options: options, into: avatarChinh)
            let uid = data?["UID"] as! String
            StorageManager.shared.downloadURL1(with: "anh1", folder: "users", subFolder: uid) { [weak self] result in
                switch result{
                case .success(let urlString):
                    let urlrq = URLRequest(url: urlString)
                    let options = ImageLoadingOptions(
                      placeholder: UIImage(systemName: "person.circle"),
                      transition: .fadeIn(duration: 0.5)
                    )
                    Nuke.loadImage(with: urlrq, options: options, into: self!.img1)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            StorageManager.shared.downloadURL1(with: "anh2", folder: "users", subFolder: uid) { [weak self] result in
                switch result{
                case .success(let urlString):
                    let urlrq = URLRequest(url: urlString)
                    let options = ImageLoadingOptions(
                      placeholder: UIImage(systemName: "person.circle"),
                      transition: .fadeIn(duration: 0.5)
                    )
                    Nuke.loadImage(with: urlrq, options: options, into: self!.img2)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            StorageManager.shared.downloadURL1(with: "anh3", folder: "users", subFolder: uid) { [weak self] result in
                switch result{
                case .success(let urlString):
                    let urlrq = URLRequest(url: urlString)
                    let options = ImageLoadingOptions(
                      placeholder: UIImage(systemName: "person.circle"),
                      transition: .fadeIn(duration: 0.5)
                    )
                    Nuke.loadImage(with: urlrq, options: options, into: self!.img3)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            StorageManager.shared.downloadURL1(with: "avatarBia", folder: "users", subFolder: uid) { [weak self] result in
                switch result{
                case .success(let urlString):
                    let urlrq = URLRequest(url: urlString)
                    let options = ImageLoadingOptions(
                      placeholder: UIImage(systemName: "person.circle"),
                      transition: .fadeIn(duration: 0.5)
                    )
                    Nuke.loadImage(with: urlrq, options: options, into: self!.avatarBia)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            fullnameLb.text = data?["fullname"] as? String
            emailLb.text = data?["email"] as? String
            dobLb.text = data?["dateOfBirth"] as? String
            genderLb.text = data?["gender"] as? String
            addressLb.text = data?["address"] as? String
            phoneLb.text = data?["phone"] as? String
            let following = data?["following"] as! [String]
            fllowingLb.text = "\(following.count) following"
            
            let followers = data?["followers"] as! [String]
            fllowerLb.text = "\(followers.count) followers"
            let user_id = data?["UID"] as! String
            db.collection("users").document(Core.shared.getCurrentUserID()).getDocument { [self] (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let following = data?["following"] as! [String]
                    
                    let index = following.firstIndex(of: user_id)
                    
                    if index != nil {
                        followBt.setTitle("UNFOLLOW", for: .normal)
                    } else {
                        followBt.setTitle("FOLLOWING", for: .normal)
                    }
                    
                }
            }
        }
    }

}
