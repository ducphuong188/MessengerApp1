//
//  LoginViewController.swift
//  MessengerApp
//
//  Created by macbook on 29/10/2023.
//

import UIKit
import Firebase
import FirebaseAuth
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn
import M13Checkbox

class LoginViewController: UIViewController {
    @IBOutlet weak var reMember: M13Checkbox!
    @IBOutlet weak var loginNormal: UIButton!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var loginGg: GIDSignInButton!
    @IBOutlet weak var loginFb: FBLoginButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    func setupView() {
        loginNormal.layer.cornerRadius = 10
        loginNormal.layer.borderWidth = 1
        userName.layer.cornerRadius = 10
        userName.layer.borderWidth = 1
        userName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        userName.placeholder = "Username..."
        userName.leftViewMode = .always
        userName.autocorrectionType = .no
        userName.autocapitalizationType = .none
        userName.returnKeyType = .continue
        passWord.layer.cornerRadius = 10
        passWord.layer.borderWidth = 1
        passWord.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        passWord.placeholder = "Password..."
        passWord.leftViewMode = .always
        passWord.autocorrectionType = .no
        passWord.autocapitalizationType = .none
        passWord.returnKeyType = .done
        
    }
    func loginFirebase() {
        let currenUserId = Auth.auth().currentUser
        let userCollection = Firestore.firestore().collection("users")
        userCollection.whereField("UID", isEqualTo: currenUserId?.uid ?? "").limit(to: 1).getDocuments { querySnapshot, error in
            guard error == nil else {
                return
            }
            if querySnapshot?.documents.count == 1 {
                let data = querySnapshot?.documents[0].data()
                let token = UUID().uuidString
                if self.reMember.checkState == M13Checkbox.CheckState.checked {
                    Core.shared.setToken(token)
                    userCollection.document(data?["UID"] as! String).updateData(["token": token])
                }
                Core.shared.setCurrentUserID(data?["UID"] as! String)
                self.loginManual()
            } else {
                let registerVC = self.presentingViewController
                self.dismiss(animated: true) {
                    let str = UIStoryboard(name: "Main", bundle: nil)
                    let vc = str.instantiateViewController(withIdentifier: "fillVC") as! FillInfoViewController
                    vc.modalPresentationStyle = .overFullScreen
                    vc.userFullName = currenUserId?.displayName ?? ""
                    vc.phone = currenUserId?.phoneNumber ?? ""
                    vc.userEmail = currenUserId?.email ?? ""
                    vc.UID = currenUserId!.uid
                    vc.token = UUID().uuidString
                    Core.shared.setToken(vc.token)
                    Core.shared.setCurrentUserID(vc.UID)
                    registerVC?.present(vc, animated: true)
                }
            }
        }
    }
    func loginManual() {
        Core.shared.setIsUserLogin(true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoadVC") as! LoadViewController
        vc.modalPresentationStyle  = .fullScreen
        Core.shared.setIsNotFirstLauchApp()
        self.present(vc, animated: true, completion: nil)
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Cảnh báo", message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Quay lại", style: .cancel)
        alert.addAction(action1)
        present(alert, animated: true)
    }
    @IBAction func tapOnLoginNor(_ sender: Any) {
        guard let userName1 = self.userName.text, !userName1.isEmpty,
                let passWord1 = self.passWord.text, !passWord1.isEmpty else {
            showAlert(message: "Bạn phải nhập đầy đủ thông tin")
            return
        }
        let userCollection = Firestore.firestore().collection("users")
        userCollection.whereField("username", isEqualTo: userName1).limit(to: 1).getDocuments { [self] (querySnapshot, error ) in
            guard error == nil else {
                return
            }
            if querySnapshot!.documents.count == 1 {
                let data = querySnapshot?.documents[0].data()
                let pass = data?["password"] as! String
                if passWord1 == pass {
                    if reMember.checkState == M13Checkbox.CheckState.checked {
                        let token = UUID().uuidString
                        Core.shared.setToken(token)
                        userCollection.document(data?["UID"] as! String).updateData(["token" : token])
                    }
                    Core.shared.setCurrentUserID(data?["UID"] as! String)
                    Core.shared.setCurrentUserEmail(data?["email"] as! String)
                    self.loginManual()
                } else {
                    showAlert(message: "tài khoản hoặc mật khẩu không chính xác!")
                }
            } else {
                showAlert(message: "tài khoản hoặc mật khẩu không chính xác!")
            }
        }
    }
    
    @IBAction func tapOnLoginFb(_ sender: Any) {
        let loginManager = LoginManager()
       
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
           
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                guard  authResult != nil, error == nil else {
                    print(error?.localizedDescription ?? "")
                    return
                }
                print("login success")
                strongSelf.loginFirebase()
            }
        }
    }
    @IBAction func tapOnLoginGg(_ sender: Any) {
        
        guard  let clientID = FirebaseApp.app()?.options.clientID else {return}
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) {  result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)
                Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                    guard let strongSelf = self else {
                        return
                    }
                    guard  authResult != nil, error == nil else {
                        print("login failed")
                        return
                    }
                    
                    print("login success")
                    strongSelf.loginFirebase()
                    
                }
            }
        }
    @IBAction func tapOnRegister(_ sender: Any) {
        let str = UIStoryboard(name: "Main", bundle: nil)
        let vc = str.instantiateViewController(withIdentifier: "registerVC")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}
