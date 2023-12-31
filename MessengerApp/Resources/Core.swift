//
//  Core.swift
//  MessengerApp
//
//  Created by macbook on 03/11/2023.
//

import Foundation
import UIKit

class Core {
    static let shared = Core()
    var isLogin = false
    var keyName = ""
    
    func isFirstLauchApp() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isFirstLauchApp")
    }
    
    func setIsNotFirstLauchApp() {
        UserDefaults.standard.setValue(true, forKey: "isFirstLauchApp")
    }
    
    func setIsFirstLauchApp() {
        UserDefaults.standard.setValue(false, forKey: "isFirstLauchApp")
    }

    func isRememberMe() -> Bool {
        return UserDefaults.standard.bool(forKey: "IsUserLogin")
    }
    
    //TO DO: add code here
    func isUserLogin() -> Bool {
        return isLogin
    }
    
    func setIsUserLogin(_ isLogin: Bool) {
        self.isLogin = isLogin
    }
    
    func setToken(_ token: String) {
        UserDefaults.standard.setValue(token, forKey: "token")
    }
    
    func getToken() -> String {
        return UserDefaults.standard.string(forKey: "token") ?? ""
    }
    
    func getCurrentUserEmail() -> String {
        return UserDefaults.standard.string(forKey: "currentEmail") ?? ""
    }
    
    func setCurrentUserEmail(_ email: String) {
        UserDefaults.standard.setValue(email, forKey: "currentEmail")
    }
    
    func getCurrentUserFullName() -> String {
        return UserDefaults.standard.string(forKey: "currentName") ?? ""
    }
    
    func setCurrentUserFullName(_ name: String) {
        UserDefaults.standard.setValue(name, forKey: "currentName")
    }
    
    func setCurrentUserID(_ UID: String) {
        UserDefaults.standard.setValue(UID, forKey: "currentUID")
    }
    
    func getCurrentUserID() -> String {
        return UserDefaults.standard.string(forKey: "currentUID") ?? ""
    }
    
    func setKeyName(_ keyName: String) {
        UserDefaults.standard.setValue(keyName, forKey: "keyName")
    }
        
    func getKeyName() -> String {
        return UserDefaults.standard.string(forKey: "keyName") ?? ""
    }
    
    func addKeySearchToHistory(key: String) {
        var searchHistoryKey = UserDefaults.standard.array(forKey: "searchHistoryKey") as? [String] ?? [String]()
        searchHistoryKey.insert(key, at: 0)
        
        UserDefaults.standard.setValue(searchHistoryKey, forKey: "searchHistoryKey")
    }
    

    //Fix not enough historyKeyLength
    func getKeySearchHistory() -> [String] {
        let searchHistoryKey = UserDefaults.standard.array(forKey: "searchHistoryKey") as? [String] ?? [String]()
        
        var result = [String]()
        let n = searchHistoryKey.count
        if (n >= 5) {
            result = Array(searchHistoryKey[0..<5])
        } else {
            result = Array(searchHistoryKey[0..<n])
        }
       
        return result
    }
    
    func clearSearchHistory() {
        UserDefaults.standard.setValue([String](), forKey: "searchHistoryKey")
    }
    
    func clearKey(index : Int) {
        var searchHistoryKey = UserDefaults.standard.array(forKey: "searchHistoryKey") as? [String] ?? [String]()
        
        searchHistoryKey.remove(at: index)
        
        UserDefaults.standard.setValue(searchHistoryKey, forKey: "searchHistoryKey")
        
    }
}

struct CurrentUser {
    var UID : String;
    var email: String;
    var fullName: String;
    var avatarImageView : UIImageView
}
extension UIView {

    public var width: CGFloat {
        return frame.size.width
    }

    public var height: CGFloat {
        return frame.size.height
    }

    public var top: CGFloat {
        return frame.origin.y
    }

    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }

    public var left: CGFloat {
        return frame.origin.x
    }

    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }

}
