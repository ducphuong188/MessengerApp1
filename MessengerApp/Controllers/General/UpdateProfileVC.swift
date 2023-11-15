//
//  UpdateProfileVC.swift
//  MessengerApp
//
//  Created by macbook on 29/10/2023.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD
import Nuke

protocol UpdateInfoDelegate: class {
    func updateChangeInfo()
}
class UpdateProfileVC: UIViewController {
    var delegate: UpdateInfoDelegate?
    @IBOutlet weak var addressTf: UITextField!
    @IBOutlet weak var genderTf: UITextField!
    @IBOutlet weak var dobTf: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var fullNameTf: UITextField!
    @IBOutlet weak var backBt: UIButton!
    var fullName = ""
    var email = ""
    var phone = ""
    var dob = ""
    var gender = ""
    var address = ""
    var isCorrect = false
    var sniper = JGProgressHUD(style: .dark)
    let titleLb: UILabel = {
       let label = UILabel()
      
        label.font = UIFont(name: "Helvetica Neue Medium", size: 20.0)
        label.textColor = UIColor(named: "AppTextColor")
        return label
   }()
   private let genderPickerView: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    let genders: [String] = ["Male", "Female"]
    let bottomView = HalfRoundedUIView()
    var datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        bottomView.isHidden = true
        datePicker.isHidden = true
        genderPickerView.isHidden = true
        view.addSubview(bottomView)
        genderTf.delegate = self
        setupView()
        initView()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        bottomView.isHidden = true
    }
    func initView () {
        fullNameTf.text = fullName
        emailTf.text = email
        phoneTf.text = phone
        dobTf.text = dob
        genderTf.text = gender
        addressTf.text = address
        backBt.layer.cornerRadius = 10
        backBt.layer.borderWidth = 1
        let textFields: [UITextField] = [fullNameTf,emailTf,phoneTf,dobTf,genderTf,addressTf]
        let labelForTFs: [String] = ["Your full name...", "Email...","phone...", "Date of birth", "Gender", "Address..."]
        for i in 0..<textFields.count {
            textFields[i].delegate = self
            textFields[i].placeholder = labelForTFs[i]
            textFields[i].leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
            textFields[i].leftViewMode = .always
            textFields[i].autocorrectionType = .no
            textFields[i].autocapitalizationType = .none
            textFields[i].layer.cornerRadius = 10
            textFields[i].layer.masksToBounds = true
            textFields[i].layer.borderWidth = 1
        }
        for i in 0..<textFields.count-1 {
            textFields[i].returnKeyType = .continue
        }
        addressTf.returnKeyType = .done
    }
    func setupView() {
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.backgroundColor = .systemGray5
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        bottomView.backgroundColor = .systemGray5
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        let bottomW = NSLayoutConstraint(item: bottomView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: view.frame.size.width)
        let bottomH = NSLayoutConstraint(item: bottomView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 350)
        let bottomX = NSLayoutConstraint(item: bottomView, attribute: .leading , relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0)
        let bottomY = NSLayoutConstraint(item: bottomView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([bottomH, bottomW, bottomX, bottomY])
        let doneButton: UIButton = {
            let button = UIButton()
            button.setTitle("DONE", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 5.0
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(named: "AppRedColor")?.cgColor
            button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 17.0)
            button.backgroundColor = .red
            button.addTarget(self, action: #selector(pickGenderDoneAct), for: .touchUpInside)
            return button
        }()
        let cancelButton: UIButton = {
            let button = UIButton()
            button.setTitle("CANCEL", for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.backgroundColor = .white
            button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 17.0)
            button.layer.cornerRadius = 5.0
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(named: "AppRedColor")?.cgColor
            button.addTarget(self, action: #selector(dismissGenderPicker), for: .touchUpInside)
            return button
        }()

        bottomView.addSubview(titleLb)
        bottomView.addSubview(doneButton)
        bottomView.addSubview(cancelButton)
        bottomView.addSubview(genderPickerView)
        bottomView.addSubview(datePicker)
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        genderPickerView.backgroundColor = .systemGray5
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        genderPickerView.translatesAutoresizingMaskIntoConstraints = false
        titleLb.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints  = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let cancelBtnWC = NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal,
                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 160)
        let cancelBtnHC = NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal,
                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44)
        let cancelBtnX = NSLayoutConstraint(item: cancelButton, attribute: .trailing, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 1, constant: -20)
        let cancelBtnY = NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1, constant: -106)
       
        let doneBtnWC = NSLayoutConstraint(item: doneButton, attribute: .width, relatedBy: .equal,
                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 160)
        let doneBtnHC = NSLayoutConstraint(item: doneButton, attribute: .height, relatedBy: .equal,
                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44)
        let doneBtnX = doneButton.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -40)
        
        let doneBtnY = NSLayoutConstraint(item: doneButton, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1, constant: -106)
        let datePickerWC = datePicker.widthAnchor.constraint(equalToConstant: view.frame.size.width)
        let datePickerHC = datePicker.heightAnchor.constraint(equalToConstant: 100)

        let datePickerY = datePicker.topAnchor.constraint(equalTo: titleLb.bottomAnchor, constant: 10)
        let datePickerX = datePicker.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 0)
//
        let genderPickerWC = genderPickerView.widthAnchor.constraint(equalToConstant: view.frame.size.width)
        let genderPickerHC = genderPickerView.heightAnchor.constraint(equalToConstant: 100)

        let genderPickerY = genderPickerView.topAnchor.constraint(equalTo: titleLb.bottomAnchor, constant: 10)
        let genderPickerX = genderPickerView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 0)
//
        let titleX = titleLb.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let titleY = titleLb.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20)
        

        NSLayoutConstraint.activate([cancelBtnWC, cancelBtnHC, cancelBtnX, cancelBtnY, doneBtnWC, doneBtnHC, doneBtnX, doneBtnY, titleX, titleY, datePickerWC, datePickerHC, datePickerY, datePickerX,genderPickerX,genderPickerY,genderPickerHC,genderPickerWC])
    }
    func checkForm() {
        fullNameTf.resignFirstResponder()
        emailTf.resignFirstResponder()
        addressTf.resignFirstResponder()
        genderTf.resignFirstResponder()
        dobTf.resignFirstResponder()
        phoneTf.resignFirstResponder()
        var result = false
        guard let fullName = fullNameTf.text,
              let email = emailTf.text,
              let gender = genderTf.text,
              let dateOfBirth = dobTf.text,
              let address = addressTf.text,
              let phone = phoneTf.text,
              !fullName.isEmpty, !email.isEmpty, !gender.isEmpty, !dateOfBirth.isEmpty, !address.isEmpty, !phone.isEmpty  else {
            showAlert(massage: "Bạn phải nhập đầy đủ thông tin")
            return
        }
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { QuerySnapshot, error in
            guard error == nil else {
                result = false
                return
            }
            if QuerySnapshot!.documents.count >= 1 {
                let data = QuerySnapshot!.documents[0].data()
                let uid = data["UID"] as! String
                
                if (uid != Core.shared.getCurrentUserID()) {
                    self.showAlert(massage: "email này đã tồn tại")
                    result = false
                } else {
                    db.collection("users").whereField("phone", isEqualTo: phone).getDocuments { QuerySnapshot, error in
                        guard error == nil else {
                            result = false
                            return
                        }
                        if QuerySnapshot!.documents.count >= 1 {
                            let data = QuerySnapshot!.documents[0].data()
                            let uid = data["UID"] as! String
                            
                            if (uid != Core.shared.getCurrentUserID()) {
                                self.showAlert(massage: "phone này đã tồn tại")
                                result = false
                            }
                            else {
                                result = true
                            }
                        } else {
                            result = true
                        }
                    }
                        
                }
                
            } else {
                db.collection("users").whereField("phone", isEqualTo: phone).getDocuments { QuerySnapshot, error in
                    guard error == nil else {
                        result = false
                        return
                    }
                    if QuerySnapshot!.documents.count >= 1 {
                        let data = QuerySnapshot!.documents[0].data()
                        let uid = data["UID"] as! String
                        
                        if (uid != Core.shared.getCurrentUserID()) {
                            self.showAlert(massage: "phone này đã tồn tại")
                            result = false
                        } else {
                            result = true
                        }
                        
                    } else {
                        result = true
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isCorrect = result
        }
    }
    func showAlert(massage: String) {
        let alert = UIAlertController(title: "Cảnh báo", message: massage, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Quay lại", style: .cancel)
        alert.addAction(action1)
        present(alert, animated: true)
    }
    func isValidEmail(email: String?) -> Bool {
        guard email != nil else { return false }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    @objc func dismissDatePicker(_ sender: Any) {
        bottomView.isHidden = true
    }
    
    
    
    @objc func dismissGenderPicker(_ sender: Any) {
        bottomView.isHidden = true
    }

    @IBAction func tapOnBack(_ sender: Any) {
        
        checkForm()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2 ) {
            [self] in
            
            if (isCorrect == true) {
                self.sniper.show(in: view)
                    let userCollection = db.collection("users")
                    
                    var user = MyUser()
                    user.UID = Core.shared.getCurrentUserID()
                    user.fullname = fullNameTf.text!
                    user.email = emailTf.text!
                    user.phone = phoneTf.text!
                    user.dateOfBirth = dobTf.text!
                    user.gender = genderTf.text!
                    user.address = addressTf.text!
                    userCollection.document(Core.shared.getCurrentUserID()).updateData([
                        "address": user.address,
                        "dateOfBirth" : user.dateOfBirth,
                        "email" : user.email,
                        "fullname" : user.fullname,
                        "gender" : user.gender,
                        "phone" : user.phone,
                    ])
                    Core.shared.setIsUserLogin(true)
                    let email = user.email
                    let fullName = user.fullname
                    Core.shared.setCurrentUserEmail(email)
                    Core.shared.setCurrentUserFullName(fullName)
                    
                    DatabaseManager.shared.updateUserName(with: ChatAppUser(fullName: fullName, emailAddress: email), completion: {
                        success in
                        if (success){
                            print("done insert realtime")
                        } else {
                            print("fail insert realtime")
                        }
                    })
                self.sniper.dismiss(animated: true)
                DispatchQueue.main.async {
                    self.delegate?.updateChangeInfo()
                    self.showAlert(massage: "Hoàn thành thay đổi thông tin")
                }
                
                
            }
        }
        
        
    }
    @objc func pickGenderDoneAct(_ sender: Any,_ textField: UITextField) {
        if titleLb.text == "Gender" {
            genderTf.text = genders[genderPickerView.selectedRow(inComponent: 0)]
            bottomView.isHidden = true
        } else if titleLb.text == "Date of birth" {
            dobTf.text = dateFormatter.string(from: datePicker.date)
            bottomView.isHidden = true
        }
        
    }

}
extension UpdateProfileVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    
}
extension UpdateProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if  textField == fullNameTf {
            emailTf.becomeFirstResponder()
        } else if textField == emailTf {
            phoneTf.becomeFirstResponder()
        } else if textField == phoneTf {
            dobTf.becomeFirstResponder()
        } else if textField == dobTf {
            genderTf.becomeFirstResponder()
        } else if textField == genderTf {
            addressTf.becomeFirstResponder()
        } else if textField == addressTf {
            tapOnBack(self)
        }
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == genderTf {
            bottomView.isHidden = false
            titleLb.text = "Gender"
            genderPickerView.isHidden = false
            datePicker.isHidden = true
        } else if textField == dobTf {
            bottomView.isHidden = false
            titleLb.text = "Date of birth"
            datePicker.isHidden = false
            genderPickerView.isHidden = true
        }
        view.endEditing(true)
        return true
    }
}
