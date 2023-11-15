//
//  LogOutVC.swift
//  MessengerApp
//
//  Created by macbook on 29/10/2023.
//

import UIKit
import FirebaseFirestore
import Nuke
class LogOutVC: UIViewController {

    @IBOutlet weak var settingBt: UIButton!
    @IBOutlet weak var avtChinh: UIImageView!
    @IBOutlet weak var inforAppBt: UIButton!
    
    @IBOutlet weak var emailLb: UILabel!
    
    @IBOutlet weak var fullnameLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
fetechData()
        avtChinh.layer.borderWidth = 2
        avtChinh.layer.masksToBounds = true
        avtChinh.contentMode = .scaleAspectFill
        avtChinh.layer.cornerRadius = avtChinh.frame.width/2
        
    }
    func fetechData() {
        db.collection("users").document(Core.shared.getCurrentUserID()).getDocument { [self] documentSnapshot, error in
            guard documentSnapshot == documentSnapshot, error == nil else {return}
            guard  let data = documentSnapshot?.data() else {return}
            let urlStr = URL(string: (data["avatar"] as! String))
            let urlReq = URLRequest(url: urlStr!)
            let options = ImageLoadingOptions(
              placeholder: UIImage(systemName: "person.circle"),
              transition: .fadeIn(duration: 0.5)
            )
            Nuke.loadImage(with: urlReq, options: options, into: avtChinh)
            fullnameLb.text = data["fullname"] as? String
            emailLb.text = data["email"] as? String
        }
    }
    @IBAction func tapOnInfor(_ sender: Any) {
    }
    @IBAction func tapOnSetting(_ sender: Any) {
    }
    
    @IBAction func tapOnlogout(_ sender: Any) {
        let alert = UIAlertController(title: "Đăng xuất", message: "Bạn thực sự muốn đăng xuất", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Đồng ý", style: .default) { [self] _ in
            tapOnLogOut()
        }
        let action1 = UIAlertAction(title: "Quay lại", style: .cancel)
        alert.addAction(action)
        alert.addAction(action1)
        present(alert, animated: true)
    }
    func tapOnLogOut() {
        let token = Core.shared.getToken()
        Core.shared.setToken("")
        
        let userCollection = Firestore.firestore().collection("users")

        userCollection.whereField("token", isEqualTo: token).limit(to: 1)
            .getDocuments{(querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    if querySnapshot!.documents.count == 1 {
                        let data = querySnapshot?.documents[0].data()
                        
                        userCollection.document(data?["UID"] as! String).updateData(["token": ""])
                        Core.shared.setCurrentUserID("")
                        
                        let vc = self.presentingViewController
                        
                        self.dismiss(animated: false, completion: {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let dest = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
                            dest.modalPresentationStyle = .fullScreen
                            vc?.present(dest, animated: false, completion: nil)
                        })

                    }
                }
            }
    }

}
