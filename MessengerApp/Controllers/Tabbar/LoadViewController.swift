//
//  LoadViewController.swift
//  MessengerApp
//
//  Created by macbook on 26/10/2023.
//

import UIKit

class LoadViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.scrollEdgeAppearance = .init(barAppearance: UINavigationBarAppearance())
        tabBar.scrollEdgeAppearance = .init(barAppearance: UITabBarAppearance())
        view.backgroundColor = .systemBackground

        let vc1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeVC") as! HomeVC
        let vc2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchVC") as! SearchVC
        let vc3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as! ProfileVC
        let vc4 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "logoutVC") as! LogOutVC
        let vc5 = UINavigationController(rootViewController: vc1)
        let vc6 = UINavigationController(rootViewController: vc2)
        let vc7 = UINavigationController(rootViewController: vc3)
        let vc8 = UINavigationController(rootViewController: vc4)
        vc1.tabBarItem.image = UIImage(systemName: "message")
        vc1.tabBarItem.title = "Chats"
        vc2.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        vc2.tabBarItem.title = "Search"
        vc3.tabBarItem.image = UIImage(systemName: "person")
        vc3.tabBarItem.title = "Profile"
        vc4.tabBarItem.image = UIImage(systemName: "power.circle")
        vc4.tabBarItem.title = "Log Out"
        tabBar.tintColor = .label
        vc1.title = "Home"
        setViewControllers([vc5, vc6, vc7, vc8], animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
}
