//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by macbook on 29/10/2023.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import JGProgressHUD
import IQKeyboardManagerSwift
class RegisterViewController: UIViewController {
    let db = Firestore.firestore()
    var isCorrect = false
    let sniper = JGProgressHUD(style: .dark)
    @IBOutlet weak var registerBt: UIButton!
    @IBOutlet weak var rePassWordTf: UITextField!
    @IBOutlet weak var passWordTf: UITextField!
    @IBOutlet weak var userNameTf: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    func setupView() {
        
        let textFields: [UITextField] = [phoneTf, userNameTf, passWordTf, rePassWordTf]
//        let leadingViews = ["ic-blue-phone","ic-blue-username", "ic-blue-password", "ic-blue-password"]
        let labelStrings = ["Phone Number...","Username...", "Password...", "Retype password..."]
       
        registerBt.layer.masksToBounds = true
        registerBt.layer.cornerRadius = 10
        for i in 0..<textFields.count {
            textFields[i].delegate = self
            textFields[i].leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
            textFields[i].leftViewMode = .always
            textFields[i].placeholder = labelStrings[i]
            textFields[i].autocorrectionType = .no
            textFields[i].autocapitalizationType = .none
            textFields[i].backgroundColor = .white
            textFields[i].layer.masksToBounds = true
            textFields[i].layer.cornerRadius = 10
            textFields[i].layer.borderWidth = 1
        }
        for i in 0..<textFields.count-1 {
            textFields[i].returnKeyType = .continue
        }
        rePassWordTf.returnKeyType = .done
    }
    @IBAction func tapOnRegister(_ sender: Any) {
        checkCorrectForm()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [self] in
            if (self.isCorrect == true) {
                let str = UIStoryboard(name: "Main", bundle: nil)
                let vc = str.instantiateViewController(withIdentifier: "fillVC") as! FillInfoViewController
                vc.modalPresentationStyle = .overFullScreen
                guard let phoneNumber = phoneTf.text,
                      let fullName = userNameTf.text,
                      let passWord = passWordTf.text else {return}
                vc.username = fullName
                vc.password = passWord
                vc.phone = phoneNumber
                self.present(vc, animated: true)
            }
        }
        
    }
    func isSame(_ password: String, _ retype: String) -> Bool {
        return password == retype
    }
    func checkCorrectForm() {
        phoneTf.resignFirstResponder()
        userNameTf.resignFirstResponder()
        passWordTf.resignFirstResponder()
        rePassWordTf.resignFirstResponder()
        var result = false
        guard let phoneNumber = phoneTf.text,
              let fullName = userNameTf.text,
              let passWord = passWordTf.text,
              let repassWord = rePassWordTf.text,
              !phoneNumber.isEmpty, !fullName.isEmpty, !passWord.isEmpty, !repassWord.isEmpty, passWord.count >= 6 else {
            showAlert(massage: "Bạn phải nhập đầy đủ thông tin")
            return
        }
        sniper.show(in: view)
        db.collection("users").whereField("username", isEqualTo: fullName).getDocuments { querySnapshot, error in
            guard  error == nil else {
                print(error as Any)
                return
            }
            if querySnapshot!.documents.count >= 1 {
                self.showAlert(massage: "user này đã tồn tại")
                result = false
            } else {
                self.db.collection("users").whereField("phone", isEqualTo: phoneNumber).getDocuments { querySnapshot, error in
                    guard  error == nil else {
                        print(error as Any)
                        return
                    }
                    if querySnapshot!.documents.count >= 1 {
                        self.showAlert(massage: "phone này đã tồn tại")
                        result = false
                    } else {
                        if (!self.isSame(passWord, repassWord)) {
                            self.showAlert(massage: "mật khẩu không trùng khớp")
                            result = false
                        } else {
                            result = true
                        }
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.sniper.dismiss()
            self.isCorrect = result
            print(self.isCorrect)
        }
    }
    func showAlert(massage: String) {
        let alert = UIAlertController(title: "Cảnh báo", message: massage, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Quay lại", style: .cancel)
        alert.addAction(action1)
        present(alert, animated: true)
    }
    @IBAction func tapOnLogin(_ sender: Any) {
        dismiss(animated: true)
    }


}
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneTf {
            userNameTf.becomeFirstResponder()
        }
        else if textField == userNameTf {
            passWordTf.becomeFirstResponder()
        } else if textField == passWordTf {
            rePassWordTf.becomeFirstResponder()
        } else if textField == rePassWordTf {
            checkCorrectForm()
        }
        return true
    }
}
