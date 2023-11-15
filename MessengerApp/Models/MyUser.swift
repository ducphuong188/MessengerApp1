//
//  MyUser.swift
//  MessengerApp
//
//  Created by macbook on 03/11/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
let db = Firestore.firestore()

struct MyUser : Identifiable, Codable {
    var id : String?
    var UID : String = ""
    var address : String = ""
    var dateOfBirth : String = ""
    var email : String = ""
    var fullname : String = ""
    var gender : String = ""
    var password : String = ""
    var phone : String = ""
    var token : String = ""
    var username : String = ""
    var avatar : String = ""
    var favorites = [String]()
    var following = [String]()
    var followers = [String]()
}
