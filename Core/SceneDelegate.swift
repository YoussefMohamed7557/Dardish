//
//  SceneDelegate.swift
//  Dardish
//
//  Created by Youssef on 12/12/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil{
            let rootVC = UIStoryboard(name: "Users", bundle: nil).instantiateViewController(identifier: "UserNavVC")
            self.window?.rootViewController = rootVC
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }



}

