//
//  ViewController.swift
//  MessengerApp
//
//  Created by macbook on 25/10/2023.
//

import UIKit
import FirebaseFirestore
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let token = Core.shared.getToken()
                if token != "" {
                    print(token)
                    let userCollection = Firestore.firestore().collection("users")
                    
                    userCollection.whereField("token", isEqualTo: token).limit(to: 1)
                        .getDocuments{ (querySnapshot, error) in
                            if let error = error {
                                print(error)
                            } else {
                                if querySnapshot!.documents.count == 1 {
                                    Core.shared.setIsUserLogin(true)
                                    print("goto main")
                                    
                                    self.gotoMain()
                                    
                                } else {
                                    self.gotoLogin()
                                }
                            }
                        }
                    
                } else {
                    self.gotoLogin()
                }
            
        }
    }
    func gotoMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
     let vc = storyboard.instantiateViewController(withIdentifier: "LoadVC") as! LoadViewController
        vc.modalPresentationStyle = .fullScreen
    
        self.present(vc, animated: false, completion: nil)
    }
    
    
    func gotoLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        vc.modalPresentationStyle = .fullScreen
            
        self.present(vc, animated: true, completion: nil)
    }

}

