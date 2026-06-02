//
//  SceneDelegate.swift
//  homework-9
//
//  Created by Кирилл Брынза on 26.05.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let tabBarController = MainTabBarController()

        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
}
