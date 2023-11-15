//
//  FillInfoViewController.swift
//  MessengerApp
//
//  Created by macbook on 29/10/2023.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import JGProgressHUD
import IQKeyboardManagerSwift
class FillInfoViewController: UIViewController {
    var username = ""
    var userFullName = ""
    var userEmail = ""
    var password = ""
    var phone = ""
    var profileImageURL = ""
    var UID = ""
    var token = ""
    let sniper = JGProgressHUD(style: .dark)
    var isCorrect = false
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
    @IBOutlet weak var backBt: UIButton!
    @IBOutlet weak var successBt: UIButton!
    
    @IBOutlet weak var viewBg: HalfRoundedUIView!
    @IBOutlet weak var addressTf: UITextField!
    @IBOutlet weak var genderTf: UITextField!
    @IBOutlet weak var dateOfBirthTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var fullNameTf: UITextField!
    @IBOutlet weak var avtarImage: UIImageView!
    let gesture = UITapGestureRecognizer(target: FillInfoViewController.self, action: #selector(didTapImage))
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        bottomView.isHidden = true
        datePicker.isHidden = true
        genderPickerView.isHidden = true
        avtarImage.contentMode = .scaleAspectFit
        avtarImage.image = UIImage(systemName: "person.circle")
        avtarImage.layer.borderWidth = 2
        avtarImage.layer.masksToBounds = true
        avtarImage.layer.cornerRadius = avtarImage.frame.width/2
        
        avtarImage.isUserInteractionEnabled = true
        avtarImage.addGestureRecognizer(gesture)
        view.addSubview(bottomView)
        setupView()
        initView()
        genderTf.delegate = self
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        bottomView.isHidden = true
    }
    func initView() {
        fullNameTf.text = userFullName
        emailTf.text = userEmail
        successBt.layer.cornerRadius = 10
        successBt.layer.borderWidth = 1
        backBt.layer.cornerRadius = 10
        backBt.layer.borderWidth = 1
        let textFields: [UITextField] = [fullNameTf,emailTf,dateOfBirthTf,genderTf,addressTf]
        let labelForTFs: [String] = ["Your full name...", "Email...", "Date of birth", "Gender", "Address..."]
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
        let bottomH = NSLayoutConstraint(item: bottomView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 280)
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
        let cancelBtnY = NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1, constant: -36)
       
        let doneBtnWC = NSLayoutConstraint(item: doneButton, attribute: .width, relatedBy: .equal,
                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 160)
        let doneBtnHC = NSLayoutConstraint(item: doneButton, attribute: .height, relatedBy: .equal,
                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44)
        let doneBtnX = doneButton.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -40)
        
        let doneBtnY = NSLayoutConstraint(item: doneButton, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1, constant: -36)
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
    @objc func didTapImage() {
        PhotoActionSheet()
        view.endEditing(true)
        
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
    func checkForm() {
        fullNameTf.resignFirstResponder()
        emailTf.resignFirstResponder()
        addressTf.resignFirstResponder()
        genderTf.resignFirstResponder()
        dateOfBirthTf.resignFirstResponder()
        var result = false
        guard let fullName = fullNameTf.text,
              let email = emailTf.text,
              let gender = genderTf.text,
              let dateOfBirth = dateOfBirthTf.text,
              let address = addressTf.text,
              !fullName.isEmpty, !email.isEmpty, !gender.isEmpty, !dateOfBirth.isEmpty, !address.isEmpty  else {
            showAlert(massage: "Bạn phải nhập đầy đủ thông tin")
            return
        }
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { QuerySnapshot, error in
            guard error == nil else {
                result = false
                return
            }
            if QuerySnapshot!.documents.count >= 1 {
                self.showAlert(massage: "email này đã tồn tại")
                result = false
            } else {
                result = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isCorrect = result
        }
    }
    @IBAction func tapOnBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func tapOnSuccess(_ sender: Any) {
        checkForm()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if (self.isCorrect) {
                self.sniper.show(in: self.view)
                let userCollection = Firestore.firestore().collection("users")
                var newUser = MyUser()
                self.UID = UUID().uuidString
                newUser.UID = self.UID
                newUser.email = self.emailTf.text!
                newUser.address = self.addressTf.text!
                newUser.dateOfBirth = self.dateOfBirthTf.text!
                newUser.gender = self.genderTf.text!
                newUser.fullname = self.fullNameTf.text!
                newUser.username = self.username
                newUser.phone = self.phone
                newUser.password = self.password
                newUser.token = self.token
                newUser.avatar = ""
                newUser.favorites = [String]()
                newUser.following = [String]()
                newUser.followers = [String]()
                guard let image = self.avtarImage.image, let data = image.pngData() else {
                    return
                }
                StorageManager.shared.uploadImage(with: data, fileName: "avatar.png", folder: "User", subFolder: self.UID, completion: { [weak self] result in
//                    guard let strongSelf = self else {
//                        return
//                    }

                    switch result {
                    case .success(let urlString):
                        // Ready to send message
                        print("Uploaded Message Photo: \(urlString)")
                        newUser.avatar = urlString
                        
                    case .failure(let error):
                        print("message photo upload error: \(error)")
                    }
                    
                    userCollection.document(newUser.UID).setData([
                            "UID": newUser.UID,
                            "address": newUser.address,
                            "avatar": newUser.avatar,
                            "dateOfBirth" : newUser.dateOfBirth,
                            "email" : newUser.email,
                            "fullname" : newUser.fullname,
                            "gender" : newUser.gender,
                            "password" : newUser.password,
                            "phone": newUser.phone,
                            "username" : newUser.username,
                            "token" : newUser.token,
                            "favorites" : newUser.favorites,
                            "following" : newUser.following,
                            "followers" : newUser.followers,
                            "is_active" : 1
                        ], merge: true)
                        
                        Core.shared.setIsUserLogin(true)
                        Core.shared.setCurrentUserID(newUser.UID)
                    
                        let email = newUser.email
                        let fullName = newUser.fullname
                    DatabaseManager.shared.insertUser(with: ChatAppUser(fullName: fullName, emailAddress: email), completion: {
                    success in
                        if (success){
                            print("done insert realtime")
                        } else {
                            print("fail insert realtime")
                        }
                    })
                        Core.shared.setCurrentUserEmail(email)
                        Core.shared.setCurrentUserFullName(fullName)
                    
                let fillInfoVC = self?.presentingViewController
                    
                self!.dismiss(animated: true, completion: {
                    self?.sniper.dismiss()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "LoadVC") as! LoadViewController
                    
                    vc.modalPresentationStyle  = .fullScreen
                    
                    Core.shared.setIsNotFirstLauchApp()
                    
                    fillInfoVC?.present(vc, animated: true, completion: nil)
                })
            })
            }
        }
    }
   
    
    @objc func dismissDatePicker(_ sender: Any) {
        bottomView.isHidden = true
    }
    
    
    
    @objc func dismissGenderPicker(_ sender: Any) {
        bottomView.isHidden = true
    }
    
    @objc func pickGenderDoneAct(_ sender: Any,_ textField: UITextField) {
        if titleLb.text == "Gender" {
            genderTf.text = genders[genderPickerView.selectedRow(inComponent: 0)]
            bottomView.isHidden = true
        } else if titleLb.text == "Date of birth" {
            dateOfBirthTf.text = dateFormatter.string(from: datePicker.date)
            bottomView.isHidden = true
        }
        
    }
    

}
extension FillInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func PhotoActionSheet() {
        let alert = UIAlertController(title: "Ảnh đại diện", message: "Bạn muốn chọn ảnh nào?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Máy ảnh", style: .default, handler: { [weak self] _ in
            self?.takePhoto()
        }))
        alert.addAction(UIAlertAction(title: "Bộ sưu tập", style: .default, handler: { [weak self] _ in
            self?.choosePhoto()
        }))
        present(alert, animated: true)
    }
    func takePhoto() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func choosePhoto() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.avtarImage.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
extension FillInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
extension FillInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if  textField == fullNameTf {
            emailTf.becomeFirstResponder()
        } else if textField == emailTf {
            dateOfBirthTf.becomeFirstResponder()
        } else if textField == dateOfBirthTf {
            genderTf.becomeFirstResponder()
        } else if textField == genderTf {
            addressTf.becomeFirstResponder()
        } else if textField == addressTf {
            tapOnSuccess(self)
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == genderTf {
            bottomView.isHidden = false
            titleLb.text = "Gender"
            genderPickerView.isHidden = false
            datePicker.isHidden = true
        } else if textField == dateOfBirthTf {
            bottomView.isHidden = false
            titleLb.text = "Date of birth"
            datePicker.isHidden = false
            genderPickerView.isHidden = true
        }
        view.endEditing(true)
        return true
    }
}
