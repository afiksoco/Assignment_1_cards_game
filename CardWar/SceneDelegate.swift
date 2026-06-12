//
//  SceneDelegate.swift
//  CardWar
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // The window + root storyboard are wired automatically when using a
        // main storyboard, so there is nothing to do here.
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}
