//
//  ProfileVC.swift
//  MessengerApp
//
//  Created by macbook on 29/10/2023.
//

import UIKit
import Nuke
import FirebaseFirestore
import SDWebImage
class ProfileVC: UIViewController {
   
    @IBOutlet weak var avtBia: UIImageView!
    
    @IBOutlet weak var avtChinh: UIImageView!
    @IBOutlet weak var fullNameLb: UILabel!
    
    @IBOutlet weak var flowingsLb: UILabel!
    @IBOutlet weak var flowerBt: UILabel!
    
    @IBOutlet weak var genderLb: UILabel!
    @IBOutlet weak var dobLb: UILabel!
    @IBOutlet weak var phoneLb: UILabel!
    @IBOutlet weak var emailLb: UILabel!
    
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image1: UIImageView!
    
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var addressLb: UILabel!
    
   
    var result1 = false
    var result2 = false
    var int1 :Int = 0
    @IBOutlet weak var lb1: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        navigationController?.navigationBar.scrollEdgeAppearance = .init(barAppearance: UINavigationBarAppearance())
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(tapOnEdit))
        avtBia.layer.borderWidth = 1
        fetchData()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapOnAvatarBia))
        let gesture1 = UITapGestureRecognizer(target: self, action: #selector(tapOnAvatarChinh))
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(tapOnImage1))
        let gesture3 = UITapGestureRecognizer(target: self, action: #selector(tapOnImage2))
        let gesture4 = UITapGestureRecognizer(target: self, action: #selector(tapOnImage3))
        let gesture5 = UITapGestureRecognizer(target: self, action: #selector(tapOnFlers))
        let gesture6 = UITapGestureRecognizer(target: self, action: #selector(tapOnFlings))
        image1.isUserInteractionEnabled = true
        image2.isUserInteractionEnabled = true
        image3.isUserInteractionEnabled = true
        avtChinh.isUserInteractionEnabled = true
        image1.addGestureRecognizer(gesture2)
        image2.addGestureRecognizer(gesture3)
        image3.addGestureRecognizer(gesture4)
        avtChinh.addGestureRecognizer(gesture1)
        avtBia.isUserInteractionEnabled = true
        avtBia.addGestureRecognizer(gesture)
        avtBia.contentMode = .scaleAspectFill
        avtChinh.layer.borderWidth = 2
        avtChinh.contentMode = .scaleAspectFill
        avtChinh.layer.masksToBounds = true
        avtChinh.layer.cornerRadius = avtChinh.frame.width/2
        image1.contentMode = .scaleAspectFill
        image2.contentMode = .scaleAspectFill
        image3.contentMode = .scaleAspectFill
        flowerBt.isUserInteractionEnabled = true
        flowerBt.addGestureRecognizer(gesture5)
        flowingsLb.isUserInteractionEnabled = true
        flowingsLb.addGestureRecognizer(gesture6)
    }
    @objc func tapOnFlings() {
        let vc = FollowingVC()
        vc.email = Core.shared.getCurrentUserEmail()
        vc.title = "followings"
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func tapOnFlers() {
        let vc = MenuVC()
        vc.email = Core.shared.getCurrentUserEmail()
        vc.title = "followers"
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func tapOnAvatarChinh() {
        int1 = 5
        avatarBia()
    }
    @objc func tapOnAvatarBia() {
        int1 = 4
        avatarBia()
        
    }
    
    @objc func tapOnImage3() {
        int1 = 3
        avatarBia()
    }
    @objc func tapOnImage2() {
        self.result1 = false
        self.result2 = true
        int1 = 2
        avatarBia()
    }
    @objc func tapOnImage1() {
        self.result1 = true
        self.result2 = false
        int1 = 1
        avatarBia()
    }
    func fetchData() {
        StorageManager.shared.downloadURL1(with: "avatarBia", folder: "users", subFolder: Core.shared.getCurrentUserID()) { [weak self] result1 in
            switch result1{
            case .success(let urlString):
                DispatchQueue.main.async {
                    self?.avtBia.sd_setImage(with: urlString)
                    
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        StorageManager.shared.downloadURL1(with: "anh1", folder: "users", subFolder: Core.shared.getCurrentUserID()) { [weak self] result1 in
            switch result1{
            case .success(let urlString):
                DispatchQueue.main.async {
                    self?.image1.sd_setImage(with: urlString)
                    
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        StorageManager.shared.downloadURL1(with: "anh2", folder: "users", subFolder: Core.shared.getCurrentUserID()) { [weak self] result1 in
            switch result1{
            case .success(let urlString):
                DispatchQueue.main.async {
                    self?.image2.sd_setImage(with: urlString)
                    
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        StorageManager.shared.downloadURL1(with: "anh3", folder: "users", subFolder: Core.shared.getCurrentUserID()) { [weak self] result1 in
            switch result1{
            case .success(let urlString):
                DispatchQueue.main.async {
                    self?.image3.sd_setImage(with: urlString)
                    
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        db.collection("users").document(Core.shared.getCurrentUserID()).getDocument { [self] documentSnapshot, error in
            guard documentSnapshot == documentSnapshot, error == nil, ((documentSnapshot?.exists) != nil) else {
                return
            }
            let data = documentSnapshot?.data()
            let urlStr = URL(string: (data?["avatar"] as! String))
            let urlReq = URLRequest(url: urlStr!)
            let options = ImageLoadingOptions(
              placeholder: UIImage(systemName: "person.circle"),
              transition: .fadeIn(duration: 0.5)
            )
            Nuke.loadImage(with: urlReq, options: options, into: avtChinh)
            fullNameLb.text = data?["fullname"] as? String
            emailLb.text = data?["email"] as? String
            dobLb.text = data?["dateOfBirth"] as? String
            genderLb.text = data?["gender"] as? String
            addressLb.text = data?["address"] as? String
            phoneLb.text = data?["phone"] as? String
            let following = data?["following"] as! [String]
            flowingsLb.text = "\(following.count) following"
            
            let followers = data?["followers"] as! [String]
            flowerBt.text = "\(followers.count) followers"
        }
    }
    
    @objc func tapOnEdit() {
        let str = UIStoryboard(name: "Main", bundle: nil)
        let vc = str.instantiateViewController(withIdentifier: "updateVC") as! UpdateProfileVC
        vc.fullName = fullNameLb.text!
        vc.email = emailLb.text!
        vc.phone = phoneLb.text!
        vc.dob = dobLb.text!
        vc.gender = genderLb.text!
        vc.address = addressLb.text!
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    
}
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func avatarBia() {
        let alert = UIAlertController(title: "Ảnh bìa", message: "Bạn muốn chọn ảnh nào?", preferredStyle: .actionSheet)
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
        guard let image = info[.editedImage] as? UIImage, let imageData = image.pngData() else {
            return
        }
        if int1 == 1 {
            StorageManager.shared.uploadImage(with: imageData, fileName: "anh1", folder: "users", subFolder: Core.shared.getCurrentUserID()) {  result1 in
                switch result1 {
                case .success(let urlString):
                    let url = URL(string: urlString)
                    let urlRq = URLRequest(url: url!)
                    let options = ImageLoadingOptions(
                      placeholder: UIImage(systemName: "person.circle"),
                      transition: .fadeIn(duration: 0.5)
                    )
                    Nuke.loadImage(with: urlRq, options: options, into: self.image1)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else if int1 == 2 {
            StorageManager.shared.uploadImage(with: imageData, fileName: "anh2", folder: "users", subFolder: Core.shared.getCurrentUserID()) {  result1 in
                switch result1 {
                case .success(let urlString):
                    let url = URL(string: urlString)
                    let urlRq = URLRequest(url: url!)
                    let options = ImageLoadingOptions(
                      placeholder: UIImage(systemName: "person.circle"),
                      transition: .fadeIn(duration: 0.5)
                    )
                    Nuke.loadImage(with: urlRq, options: options, into: self.image2)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else if int1 == 3 {
            StorageManager.shared.uploadImage(with: imageData, fileName: "anh3", folder: "users", subFolder: Core.shared.getCurrentUserID()) {   result1 in
                switch result1 {
                case .success(let urlString):
                    let url = URL(string: urlString)
                    let urlRq = URLRequest(url: url!)
                    let options = ImageLoadingOptions(
                      placeholder: UIImage(systemName: "person.circle"),
                      transition: .fadeIn(duration: 0.5)
                    )
                    Nuke.loadImage(with: urlRq, options: options, into: self.image3)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else if int1 == 4 {
            StorageManager.shared.uploadImage(with: imageData, fileName: "avatarBia", folder: "users", subFolder: Core.shared.getCurrentUserID()) {   result1 in
                switch result1 {
                case .success(let urlString):
                    let url = URL(string: urlString)
                    let urlRq = URLRequest(url: url!)
                    let options = ImageLoadingOptions(
                      placeholder: UIImage(systemName: "person.circle"),
                      transition: .fadeIn(duration: 0.5)
                    )
                    Nuke.loadImage(with: urlRq, options: options, into: self.avtBia)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else if int1 == 5 {
            StorageManager.shared.uploadImage(with: imageData, fileName: "avatarChinh", folder: "users", subFolder: Core.shared.getCurrentUserID()) {   result1 in
                switch result1 {
                case .success(let urlString):
                    db.collection("users").document(Core.shared.getCurrentUserID()).updateData(["avatar" : urlString])
                    let url = URL(string: urlString)
                    let urlRq = URLRequest(url: url!)
                    let options = ImageLoadingOptions(
                      placeholder: UIImage(systemName: "person.circle"),
                      transition: .fadeIn(duration: 0.5)
                    )
                    Nuke.loadImage(with: urlRq, options: options, into: self.avtChinh)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
extension ProfileVC: UpdateInfoDelegate {
    func updateChangeInfo() {
        fetchData()
    }
    
    
}
